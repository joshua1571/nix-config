{ pkgs, ... }:
{
  services.netdata = {
    enable = true;

    # Bind only to loopback; the UI is reached via the nginx reverse proxy
    # over tailscale.
    config = {
      web = {
        "bind to" = "127.0.0.1";
      };
    };

    # Route health alarms to the local ntfy server so they land on the phone.
    # Netdata sources this file and calls custom_sender() for any alarm whose
    # recipient list resolves to the custom channel.
    configDir = {
      "health_alarm_notify.conf" = pkgs.writeText "health_alarm_notify.conf" ''
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
    };
  };
}
