{ config, pkgs, ... }:
let
  certDir = "/var/lib/nginx/tailscale-certs";

  # Reusable proxy header/timeout block. Parameterised by the value used for
  # the X-Forwarded-For header, so authed locations can pin XFF to loopback
  # (see autheliaSnippet). Mirrors what services.nginx.recommendedProxySettings
  # would inject, but per-location so we control the XFF value.
  # Note: intentionally omits `proxy_http_version 1.1` + `Connection ""`
  # (upstream keep-alive optimisation) because they collide with the
  # `proxy_http_version` directive that `proxyWebsockets = true` injects,
  # and nginx errors on a duplicate proxy_http_version. Not required for
  # correctness.
  #
  # `hostVal` is the value passed as the upstream Host header — defaults
  # to $host (client's Host) but can be overridden for upstreams whose
  # nginx vhost server_name doesn't match the client-facing FQDN
  # (Nextcloud sets server_name = "server", so its location passes
  # hostVal = "server" to match).
  # `xffVal` is the value for X-Forwarded-For — normally
  # $proxy_add_x_forwarded_for, but autheliaSnippet pins it to loopback
  # so upstream "local address" heuristics treat authed requests as local.
  proxyBase =
    {
      hostVal ? "$host",
      xffVal ? "$proxy_add_x_forwarded_for",
    }:
    ''
      proxy_redirect         off;
      proxy_connect_timeout  60s;
      proxy_send_timeout     60s;
      proxy_read_timeout     60s;
      proxy_set_header       Host              ${hostVal};
      proxy_set_header       X-Real-IP         $remote_addr;
      proxy_set_header       X-Forwarded-For   ${xffVal};
      proxy_set_header       X-Forwarded-Proto $scheme;
      proxy_set_header       X-Forwarded-Host  $host;
    '';

  # Default headers for locations that don't need Authelia gating.
  proxyHeaders = proxyBase { };

  # Attach to any location that should require Authelia authentication.
  # Emits the auth_request subrequest, forwards Authelia's identity
  # response headers to the upstream, redirects unauth'd users to the
  # portal, and pins X-Forwarded-For to loopback. The XFF pin exists so
  # upstreams whose "local address" auth-bypass honors XFF (Radarr et al.'s
  # DisabledForLocalAddresses) treat the reverse-proxied request as local
  # — Authelia has already answered "who is this" at the nginx layer.
  autheliaSnippet = ''
    auth_request /internal/authelia/authz;
    auth_request_set $target_url $scheme://$http_host$request_uri;
    auth_request_set $user       $upstream_http_remote_user;
    auth_request_set $groups     $upstream_http_remote_groups;
    auth_request_set $name       $upstream_http_remote_name;
    auth_request_set $email      $upstream_http_remote_email;
    proxy_set_header Remote-User   $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Name   $name;
    proxy_set_header Remote-Email  $email;
    error_page 401 =302 https://$http_host/authelia/?rd=$target_url;
  ''
  + proxyBase { xffVal = "127.0.0.1"; };
in
{
  # Decrypt the tailscale hostname secret at boot
  age.secrets.tailscale-hostname = {
    file = ../../secrets/tailscale-hostname.age;
    owner = "root";
    mode = "0400";
  };

  # Allow nginx to provision Tailscale TLS certificates
  services.tailscale.permitCertUid = "nginx";

  # Provision the Tailscale TLS cert on startup and renew it weekly.
  # The hostname is read at runtime from the agenix-decrypted secret.
  # Note: the machine must be authenticated to Tailscale before this runs.
  systemd = {
    tmpfiles.rules = [
      "d ${certDir} 0750 root nginx - -"
    ];

    services.tailscale-cert = {
      description = "Provision Tailscale TLS certificate for nginx";
      after = [
        "tailscaled.service"
        "network-online.target"
        "agenix.service"
      ];
      before = [ "nginx.service" ];
      wantedBy = [ "nginx.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        hostname=$(cat ${config.age.secrets.tailscale-hostname.path})
        ${pkgs.tailscale}/bin/tailscale cert \
          --cert-file ${certDir}/cert.pem \
          --key-file ${certDir}/key.pem \
          "$hostname"
        # tailscale writes key.pem as root:root 0600; nginx runs as uid nginx
        # and can't read it. Regrant to the nginx group each run.
        chown root:nginx ${certDir}/cert.pem ${certDir}/key.pem
        chmod 0640 ${certDir}/key.pem
      '';
    };

    timers.tailscale-cert = {
      description = "Renew Tailscale TLS certificate weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };

  services.nginx = {
    enable = true;
    # Disabled because it injects proxy_set_header for XFF at a level we
    # can't override per-location. We add the equivalent via proxyBase/
    # proxyHeaders/autheliaSnippet so we can pin XFF for authed locations.
    recommendedProxySettings = false;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    # Expose stub_status on 127.0.0.1/nginx_status for the prometheus
    # nginx exporter. The upstream module adds a dedicated localhost
    # vhost restricted to loopback; safe alongside the other :80 vhosts.
    statusPage = true;

    # Dedicated HTTPS listener for Immich (:2443). Immich doesn't support
    # subpath serving, so it can't sit under the main catch-all — same
    # tailscale cert, different port. OIDC callbacks are HTTPS-only for
    # non-loopback targets, hence not just proxying HTTP :2283 directly.
    virtualHosts."_immich" = {
      # `onlySSL` is what actually wires ssl_certificate directives into
      # the server block — `listen.ssl = true` alone isn't enough because
      # nixpkgs derives hasSSL only from addSSL/forceSSL/onlySSL/ACME
      # options, not from the listen list.
      onlySSL = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 2443;
          ssl = true;
        }
      ];
      sslCertificate = "${certDir}/cert.pem";
      sslCertificateKey = "${certDir}/key.pem";
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
        extraConfig = proxyHeaders + ''
          # Photo/video uploads need generous body-size limits.
          client_max_body_size 50G;
        '';
      };
    };

    # server_name _ is a catch-all — no hostname needed at build time.
    # Access control is handled at the network level by Tailscale.
    virtualHosts."_" = {
      onlySSL = true;
      sslCertificate = "${certDir}/cert.pem";
      sslCertificateKey = "${certDir}/key.pem";

      locations = {
        # Authelia portal. `server.address` in authelia.nix already includes
        # the /authelia prefix, so pass the URI through unmodified (no
        # trailing slash on proxyPass). Authelia relies on the X-Forwarded-*
        # headers below to construct its own redirects.
        "/authelia/" = {
          proxyPass = "http://127.0.0.1:9091";
          extraConfig = proxyHeaders + ''
            proxy_set_header X-Forwarded-Method $request_method;
            proxy_set_header X-Forwarded-URI    $request_uri;
          '';
        };

        # Internal target for auth_request. Not reachable from outside
        # thanks to the `internal;` directive; only nginx subrequests hit it.
        "= /internal/authelia/authz" = {
          extraConfig = ''
            internal;
            proxy_pass                         http://127.0.0.1:9091/authelia/api/authz/auth-request;
            proxy_pass_request_body            off;
            proxy_set_header Content-Length    "";
            proxy_set_header Host              $host;
            proxy_set_header X-Original-Method $request_method;
            proxy_set_header X-Original-URL    $scheme://$http_host$request_uri;
            proxy_set_header X-Forwarded-For   $remote_addr;
          '';
        };

        # Homepage Dashboard
        # Note: add your tailscale hostname to allowedHosts in homepage-dashboard.nix
        # Widget backend calls run server-side (homepage → 127.0.0.1:<port>)
        # and bypass nginx entirely, so tile data keeps updating behind SSO.
        "/" = {
          proxyPass = "http://127.0.0.1:8082";
          extraConfig = autheliaSnippet;
        };

        # Jellyfin — Base URL = "/jellyfin" in Jellyfin → Dashboard →
        # Networking. Since Jellyfin serves under that prefix, the prefix
        # must reach it (no trailing slash on proxyPass) — otherwise
        # frontend-generated URLs double the prefix (/jellyfin/jellyfin/...)
        # once the SPA loads.
        "/jellyfin/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          extraConfig = proxyHeaders;
        };

        # Navidrome — BaseUrl = "/navidrome" is set in navidrome.nix, so
        # the /navidrome/ prefix must be preserved (no trailing slash on proxyPass).
        "/navidrome/" = {
          proxyPass = "http://127.0.0.1:4533";
          extraConfig = proxyHeaders;
        };

        # Jellyseerr — does not support URL base paths, so it's not proxied
        # here. Reached directly on port 5055 over tailscale/LAN instead.

        # *arr stack — admin services, tailscale only.
        # URL Base must be set in each app's Settings → General to match the
        # location prefix (e.g. /radarr). No trailing slash on proxyPass so
        # nginx preserves the prefix when forwarding.
        "/radarr/" = {
          proxyPass = "http://127.0.0.1:7878";
          extraConfig = autheliaSnippet;
        };
        "/sonarr/" = {
          proxyPass = "http://127.0.0.1:8989";
          extraConfig = autheliaSnippet;
        };
        "/lidarr/" = {
          proxyPass = "http://127.0.0.1:8686";
          extraConfig = autheliaSnippet;
        };
        "/prowlarr/" = {
          proxyPass = "http://127.0.0.1:9696";
          extraConfig = autheliaSnippet;
        };

        # qBittorrent — nginx reaches it via loopback, allowed by the kill
        # switch. qBittorrent's own auth is disabled for loopback peers
        # (LocalHostAuth=false in qbittorrent.nix), so no in-app auth toggle
        # is needed alongside forward-auth.
        "/qbittorrent/" = {
          proxyPass = "http://127.0.0.1:8080/";
          proxyWebsockets = true;
          extraConfig = autheliaSnippet;
        };

        # Prometheus + Alertmanager — both bind loopback and serve under
        # their own --web.route-prefix, so we forward the URI intact
        # (no trailing slash on proxyPass).
        "/prometheus/" = {
          proxyPass = "http://127.0.0.1:9090";
          extraConfig = autheliaSnippet;
        };
        "/alertmanager/" = {
          proxyPass = "http://127.0.0.1:9093";
          extraConfig = autheliaSnippet;
        };

        # Grafana — auth is delegated to Authelia via OIDC, so use plain
        # proxyHeaders (not autheliaSnippet). Grafana serves under /grafana
        # via GF_SERVER_SERVE_FROM_SUB_PATH; no trailing slash on proxyPass
        # so the prefix reaches Grafana intact.
        "/grafana/" = {
          proxyPass = "http://127.0.0.1:3000";
          extraConfig = proxyHeaders;
        };

        # Nextcloud — proxied to the module-managed vhost on :80. That
        # vhost's server_name is "server" (nextcloud.hostName), so the
        # upstream Host header has to match: we pass hostVal = "server"
        # instead of the client-facing FQDN.
        # The trailing slash on proxyPass strips the /nextcloud/ prefix;
        # Nextcloud regenerates externally-visible URLs under /nextcloud
        # via overwritewebroot (see nextcloud.nix).
        # client_max_body_size must match services.nextcloud.maxUploadSize.
        "/nextcloud/" = {
          proxyPass = "http://127.0.0.1:80/";
          extraConfig = proxyBase { hostVal = "server"; } + ''
            client_max_body_size 16G;
          '';
        };

        # CardDAV / CalDAV / webfinger / nodeinfo autodiscovery. Clients
        # probe these at the site root; Nextcloud expects them under its
        # webroot, so redirect to /nextcloud/... . Nextcloud emits the
        # 30x back to /nextcloud/remote.php/dav from there.
        "= /.well-known/carddav".return = "301 /nextcloud/remote.php/dav";
        "= /.well-known/caldav".return = "301 /nextcloud/remote.php/dav";
        "= /.well-known/webfinger".return = "301 /nextcloud/index.php/.well-known/webfinger";
        "= /.well-known/nodeinfo".return = "301 /nextcloud/index.php/.well-known/nodeinfo";

        # FreshRSS — served by its own nginx vhost bound to 127.0.0.1:8083
        # (see freshrss.nix). Trailing slash on proxyPass strips the
        # /freshrss/ prefix before forwarding, since the freshrss vhost
        # itself serves at root.
        # proxy_cookie_path rewrites the Set-Cookie path from FreshRSS's
        # runtime-derived /i/ (SCRIPT_NAME=/i/index.php after prefix strip)
        # to /freshrss/i/ so the browser actually sends the session cookie
        # back on subsequent requests. Without this, login fails with
        # "cookies required for PHP sessions."
        # autheliaSnippet gates access AND forwards Remote-User to the
        # loopback vhost, which passes it to PHP-FPM as REMOTE_USER (see
        # freshrss.nix); FreshRSS's HTTP-auth mode consumes it for SSO.
        "/freshrss/" = {
          proxyPass = "http://127.0.0.1:8083/";
          extraConfig = autheliaSnippet + ''
            proxy_cookie_path / /freshrss/;
          '';
        };
      };
    };
  };

  # Expose HTTPS on the tailscale interface only.
  # LAN-accessible services (Jellyfin, Navidrome, Jellyseerr, Homepage) remain
  # reachable on their original ports via openFirewall = true in their modules.
  # 2443 is the dedicated Immich HTTPS listener (see _immich vhost above).
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    443
    2443
  ];
}
