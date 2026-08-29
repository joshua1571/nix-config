_:
let
  # Standard alert: notify after 3 consecutive failures, and again on recovery.
  # Matches gatus's built-in ntfy provider config below.
  defaultAlerts = [
    {
      type = "ntfy";
      failure-threshold = 3;
      success-threshold = 2;
      send-on-resolved = true;
      description = "healthcheck failed";
    }
  ];

  # HTTP endpoint helper — all local services follow the same pattern:
  # accept anything under 4xx (some services 302 to a login page).
  http = name: group: url: {
    inherit name group url;
    interval = "60s";
    conditions = [ "[STATUS] < 400" ];
    alerts = defaultAlerts;
  };
in
{
  services.gatus = {
    enable = true;
    settings = {
      web = {
        address = "0.0.0.0";
        port = 8084;
      };

      # Persist uptime history across restarts. Without this gatus uses
      # in-memory storage and loses all history on rebuild.
      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
      };

      # Route alerts to the local ntfy server. Phone subscribes to
      # `server-uptime` to receive them.
      alerting.ntfy = {
        url = "http://127.0.0.1:8085";
        topic = "server-uptime";
        # ntfy priority: 1=min, 3=default, 5=max
        priority = 4;
      };

      # UI settings — small, self-hosted, no external CDN needed.
      ui = {
        title = "Server Uptime";
        header = "Server Uptime";
      };

      endpoints = [
        # Media
        (http "jellyfin" "media" "http://127.0.0.1:8096/health")
        (http "navidrome" "media" "http://127.0.0.1:4533/navidrome/ping")
        (http "immich" "media" "http://127.0.0.1:2283/api/server/ping")
        (http "jellyseerr" "media" "http://127.0.0.1:5055/api/v1/status")

        # Arr stack
        (http "radarr" "arr" "http://127.0.0.1:7878/radarr/ping")
        (http "sonarr" "arr" "http://127.0.0.1:8989/sonarr/ping")
        (http "lidarr" "arr" "http://127.0.0.1:8686/lidarr/ping")
        (http "prowlarr" "arr" "http://127.0.0.1:9696/prowlarr/ping")
        (http "qbittorrent" "arr" "http://127.0.0.1:8080")

        # Personal
        # freshrss serves the app at /i/ on port 8083; root 302s to a path
        # that only resolves behind the nginx prefix-stripping proxy.
        (http "freshrss" "personal" "http://127.0.0.1:8083/i/")
        # nextcloud vhost lives on :80; status.php answers 200 with no redirect.
        (http "nextcloud" "personal" "http://127.0.0.1/status.php")

        # Infrastructure
        (http "homepage" "infra" "http://127.0.0.1:8082")
        (http "ntfy" "infra" "http://127.0.0.1:8085/v1/health")
        (http "netdata" "infra" "http://127.0.0.1:19999/api/v1/info")
        (http "gatus-self" "infra" "http://127.0.0.1:8084/health")
      ];
    };
  };

  # Expose gatus's status page on the tailscale/LAN interface.
  networking.firewall.allowedTCPPorts = [ 8084 ];
}
