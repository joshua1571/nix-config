{ config, pkgs, ... }:
let
  certDir = "/var/lib/nginx/tailscale-certs";
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
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    # Expose stub_status on 127.0.0.1/nginx_status for the prometheus
    # nginx exporter. The upstream module adds a dedicated localhost
    # vhost restricted to loopback; safe alongside the other :80 vhosts.
    statusPage = true;

    # server_name _ is a catch-all — no hostname needed at build time.
    # Access control is handled at the network level by Tailscale.
    virtualHosts."_" = {
      onlySSL = true;
      sslCertificate = "${certDir}/cert.pem";
      sslCertificateKey = "${certDir}/key.pem";

      locations = {
        # Homepage Dashboard
        # Note: add your tailscale hostname to allowedHosts in homepage-dashboard.nix
        "/" = {
          proxyPass = "http://127.0.0.1:8082";
        };

        # Jellyfin
        # Note: set Base URL to /jellyfin in Jellyfin → Dashboard → Networking
        "/jellyfin/" = {
          proxyPass = "http://127.0.0.1:8096/";
          proxyWebsockets = true;
        };

        # Navidrome — BaseUrl = "/navidrome" is set in navidrome.nix, so
        # the /navidrome/ prefix must be preserved (no trailing slash on proxyPass).
        "/navidrome/" = {
          proxyPass = "http://127.0.0.1:4533";
        };

        # Jellyseerr — does not support URL base paths, so it's not proxied
        # here. Reached directly on port 5055 over tailscale/LAN instead.

        # *arr stack — admin services, tailscale only.
        # URL Base must be set in each app's Settings → General to match the
        # location prefix (e.g. /radarr). No trailing slash on proxyPass so
        # nginx preserves the prefix when forwarding.
        "/radarr/" = {
          proxyPass = "http://127.0.0.1:7878";
        };
        "/sonarr/" = {
          proxyPass = "http://127.0.0.1:8989";
        };
        "/lidarr/" = {
          proxyPass = "http://127.0.0.1:8686";
        };
        "/prowlarr/" = {
          proxyPass = "http://127.0.0.1:9696";
        };

        # qBittorrent — nginx reaches it via loopback, allowed by the kill switch
        "/qbittorrent/" = {
          proxyPass = "http://127.0.0.1:8080/";
          proxyWebsockets = true;
        };

        # Nextcloud — proxied to the module-managed vhost on :80, which is
        # the only listener on port 80 so it serves any Host. The include
        # from recommendedProxySettings is appended after extraConfig and
        # already sets `proxy_set_header Host $host;` — adding a second
        # `Host` directive here would send two Host headers upstream,
        # which nginx rejects with 400. Leave Host handling to the include.
        # The trailing slash on proxyPass strips the /nextcloud/ prefix;
        # Nextcloud regenerates externally-visible URLs under /nextcloud
        # via overwritewebroot (see nextcloud.nix).
        # client_max_body_size must match services.nextcloud.maxUploadSize.
        "/nextcloud/" = {
          proxyPass = "http://127.0.0.1:80/";
          extraConfig = ''
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
        "/freshrss/" = {
          proxyPass = "http://127.0.0.1:8083/";
          extraConfig = ''
            proxy_cookie_path / /freshrss/;
          '';
        };
      };
    };
  };

  # Expose HTTPS on the tailscale interface only.
  # LAN-accessible services (Jellyfin, Navidrome, Jellyseerr, Homepage) remain
  # reachable on their original ports via openFirewall = true in their modules.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 443 ];
}
