{ pkgs, lib, ... }:
let
  # Critical services: instrument each with OnFailure=notify-failure@%n so
  # that any transition into failed state pushes a notification to ntfy,
  # independent of whether gatus's HTTP checks catch the outage.
  criticalServices = [
    "jellyfin"
    "navidrome"
    "immich-server"
    "immich-machine-learning"
    "jellyseerr"
    "radarr"
    "sonarr"
    "lidarr"
    "prowlarr"
    "qbittorrent"
    "freshrss"
    "phpfpm-freshrss"
    "phpfpm-nextcloud"
    "nextcloud-setup"
    "homepage-dashboard"
    "nginx"
    "netdata"
    "gatus"
    "ntfy-sh"
    "postgresql"
    "redis-immich"
    "redis-nextcloud"
  ];
in
{
  systemd.services =
    # Template unit systemd instantiates as `notify-failure@<unit>.service`
    # when OnFailure fires. %i is the failed unit's name; systemctl status
    # is piped into the ntfy body so the alert includes error context.
    {
      "notify-failure@" = {
        description = "Push systemd unit failure to ntfy (%i)";
        serviceConfig.Type = "oneshot";
        scriptArgs = "%i";
        script = ''
          unit="$1"
          status=$(${pkgs.systemd}/bin/systemctl status --no-pager --lines=20 "$unit" 2>&1 || true)
          ${pkgs.curl}/bin/curl \
            --silent --show-error --max-time 10 \
            -H "Title: systemd failed: $unit" \
            -H "Priority: high" \
            -H "Tags: rotating_light" \
            -d "$status" \
            http://127.0.0.1:8085/server-alerts >/dev/null
        '';
      };
    }
    // lib.listToAttrs (
      map (name: {
        inherit name;
        value.onFailure = [ "notify-failure@%n.service" ];
      }) criticalServices
    );
}
