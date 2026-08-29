{ pkgs, ... }:
{
  # Belt-and-suspenders check on top of netdata's built-in zfspool alarms.
  # Runs `zpool status -x` daily; if any pool is degraded / faulted / has
  # errors, push the full status output to ntfy. Exit code is always 0, so
  # branch on the "all pools are healthy" sentinel.
  systemd.services.zfs-health-check = {
    description = "Check ZFS pool health and notify ntfy on issues";
    after = [ "zfs.target" ];
    wants = [ "zfs.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      output=$(${pkgs.zfs}/bin/zpool status -x)
      if [ "$output" != "all pools are healthy" ]; then
          ${pkgs.curl}/bin/curl \
              --silent --show-error --max-time 10 \
              -H "Title: ZFS pool unhealthy" \
              -H "Priority: urgent" \
              -H "Tags: rotating_light,floppy_disk" \
              -d "$output" \
              http://127.0.0.1:8085/server-alerts >/dev/null
      fi
    '';
  };

  systemd.timers.zfs-health-check = {
    description = "Run ZFS health check daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
