_: {
  services.prometheus = {
    # Purpose-built bridge that translates alertmanager's webhook payload
    # into ntfy publishes with formatted titles/priorities/tags. Loopback
    # only — alertmanager is the sole client.
    alertmanager-ntfy = {
      enable = true;
      settings = {
        http.addr = "127.0.0.1:9088";
        ntfy = {
          baseurl = "http://127.0.0.1:8085";
          notification.topic = "server-alerts";
        };
      };
    };

    alertmanager = {
      enable = true;
      port = 9093;
      # Loopback-only; reached via nginx at /alertmanager/ behind Authelia.
      listenAddress = "127.0.0.1";
      # Serve UI + endpoints under /alertmanager. See prometheus.nix
      # `alertmanagers.path_prefix` which mirrors this.
      extraFlags = [ "--web.route-prefix=/alertmanager" ];
      configuration = {
        route = {
          receiver = "ntfy";
          group_by = [ "alertname" ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "12h";
        };
        receivers = [
          {
            name = "ntfy";
            webhook_configs = [
              {
                url = "http://127.0.0.1:9088/alertmanager";
                send_resolved = true;
              }
            ];
          }
        ];
      };
    };

    # Wire prometheus to send firing alerts to the local alertmanager.
    # path_prefix matches alertmanager's --web.route-prefix so the POST
    # lands on /alertmanager/api/v2/alerts, not /api/v2/alerts.
    alertmanagers = [
      {
        static_configs = [ { targets = [ "127.0.0.1:9093" ]; } ];
        path_prefix = "/alertmanager";
      }
    ];
  };
}
