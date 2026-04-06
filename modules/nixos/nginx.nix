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

  systemd.tmpfiles.rules = [
    "d ${certDir} 0750 root nginx - -"
  ];

  # Provision the Tailscale TLS cert on startup and renew it weekly.
  # The hostname is read at runtime from the agenix-decrypted secret.
  # Note: the machine must be authenticated to Tailscale before this runs.
  systemd.services.tailscale-cert = {
    description = "Provision Tailscale TLS certificate for nginx";
    after = [ "tailscaled.service" "network-online.target" "agenix.service" ];
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
    '';
  };

  systemd.timers.tailscale-cert = {
    description = "Renew Tailscale TLS certificate weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    # server_name _ is a catch-all — no hostname needed at build time.
    # Access control is handled at the network level by Tailscale.
    virtualHosts."_" = {
      onlySSL = true;
      sslCertificate = "${certDir}/cert.pem";
      sslCertificateKey = "${certDir}/key.pem";

      # Homepage Dashboard
      # Note: add your tailscale hostname to allowedHosts in homepage-dashboard.nix
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
      };

      # Jellyfin
      # Note: set Base URL to /jellyfin in Jellyfin → Dashboard → Networking
      locations."/jellyfin/" = {
        proxyPass = "http://127.0.0.1:8096/";
        proxyWebsockets = true;
      };

      # Navidrome
      # Note: add BaseUrl = "/navidrome" to navidrome.nix settings
      locations."/navidrome/" = {
        proxyPass = "http://127.0.0.1:4533/";
      };

      # Jellyseerr
      locations."/jellyseerr/" = {
        proxyPass = "http://127.0.0.1:5055/";
      };

      # *arr stack — admin services, tailscale only
      # Note: set URL Base in each app's Settings → General
      locations."/radarr/" = {
        proxyPass = "http://127.0.0.1:7878/";
      };
      locations."/sonarr/" = {
        proxyPass = "http://127.0.0.1:8989/";
      };
      locations."/lidarr/" = {
        proxyPass = "http://127.0.0.1:8686/";
      };
      locations."/prowlarr/" = {
        proxyPass = "http://127.0.0.1:9696/";
      };

      # qBittorrent — nginx reaches it via loopback, allowed by the kill switch
      locations."/qbittorrent/" = {
        proxyPass = "http://127.0.0.1:8080/";
        proxyWebsockets = true;
      };
    };
  };

  # Expose HTTPS on the tailscale interface only.
  # LAN-accessible services (Jellyfin, Navidrome, Jellyseerr, Homepage) remain
  # reachable on their original ports via openFirewall = true in their modules.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 443 ];
}
