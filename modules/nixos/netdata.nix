{ pkgs, ... }:
{
  services.netdata = {
    enable = true;
    # The nixpkgs netdata package omits the dashboard bundle by default
    # (opt-in due to the non-commercial ncul1 license on the Cloud UI).
    # Without this, / returns 400 and the browser shows "file does not
    # exist or is not accessible" for every panel.
    package = pkgs.netdata.override { withCloudUi = true; };
  };

  # Route health alarms to the local ntfy server so they land on the phone.
  # This file must live at /etc/netdata/health_alarm_notify.conf directly —
  # services.netdata.configDir places files under /etc/netdata/conf.d/, which
  # netdata's alarm engine does not source.
  environment.etc."netdata/health_alarm_notify.conf".source =
    pkgs.writeText "health_alarm_notify.conf" ''
      SEND_CUSTOM="YES"
      DEFAULT_RECIPIENT_CUSTOM="server-alerts"

      # $to, $host, $status, $name, $chart, $value, $units, $info, $severity
      # are set by netdata before invoking this function.
      custom_sender() {
          # Map netdata alarm status to an ntfy priority + tag.
          local priority="default"
          local tag="information_source"
          case "''${status}" in
              CRITICAL) priority="urgent"; tag="rotating_light" ;;
              WARNING)  priority="high";   tag="warning" ;;
              CLEAR)    priority="low";    tag="white_check_mark" ;;
          esac

          ${pkgs.curl}/bin/curl \
              --silent --show-error --max-time 10 \
              -H "Title: netdata [''${host}] ''${status}: ''${name}" \
              -H "Priority: ''${priority}" \
              -H "Tags: ''${tag}" \
              -d "''${chart}.''${name} = ''${value} ''${units}
      ''${info}" \
              "http://127.0.0.1:8085/''${to}" >/dev/null
      }
    '';

  # Expose netdata's UI on the tailscale/LAN interface (port 19999).
  networking.firewall.allowedTCPPorts = [ 19999 ];
}
