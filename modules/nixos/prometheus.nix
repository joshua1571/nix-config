_: {
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "0.0.0.0";

    # Lower polling and retention below defaults (1m / 15d) to keep the
    # resource cost close to the netdata setup this replaces.
    globalConfig = {
      scrape_interval = "2m";
      evaluation_interval = "1m";
    };
    retentionTime = "7d";

    # All exporters bind to loopback; only prometheus scrapes them.
    exporters = {
      node = {
        enable = true;
        port = 9100;
        listenAddress = "127.0.0.1";
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
      zfs = {
        enable = true;
        port = 9134;
        listenAddress = "127.0.0.1";
      };
      systemd = {
        enable = true;
        port = 9558;
        listenAddress = "127.0.0.1";
      };
      nginx = {
        enable = true;
        port = 9113;
        listenAddress = "127.0.0.1";
        scrapeUri = "http://127.0.0.1/nginx_status";
      };
      postgres = {
        enable = true;
        port = 9187;
        listenAddress = "127.0.0.1";
        # Runs as the postgres system user and connects over the unix
        # socket via peer auth — no dedicated DB role or password secret.
        runAsLocalSuperUser = true;
      };
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "127.0.0.1:9090" ]; } ];
      }
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
      }
      {
        job_name = "zfs";
        static_configs = [ { targets = [ "127.0.0.1:9134" ]; } ];
      }
      {
        job_name = "systemd";
        static_configs = [ { targets = [ "127.0.0.1:9558" ]; } ];
      }
      {
        job_name = "nginx";
        static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
      }
      {
        job_name = "postgres";
        static_configs = [ { targets = [ "127.0.0.1:9187" ]; } ];
      }
    ];

    # Alert rules — the strings are YAML documents parsed by prometheus.
    # Aiming for signal, not noise: durations chosen so a transient blip
    # doesn't page.
    rules = [
      ''
        groups:
          - name: host
            rules:
              - alert: TargetDown
                expr: up == 0
                for: 5m
                annotations:
                  summary: "Scrape target {{ $labels.job }} down"
                  description: "{{ $labels.instance }} of job {{ $labels.job }} unreachable for 5m."
              - alert: HighLoad
                expr: node_load1 > count by (instance) (node_cpu_seconds_total{mode="idle"}) * 2
                for: 10m
                annotations:
                  summary: "High load on {{ $labels.instance }}"
                  description: "1m load {{ $value }} is above 2x CPU count."
              - alert: LowMemory
                expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.10
                for: 10m
                annotations:
                  summary: "Low available memory on {{ $labels.instance }}"
                  description: "Only {{ $value | humanizePercentage }} available."
              - alert: LowDiskSpace
                expr: node_filesystem_avail_bytes{fstype!~"tmpfs|overlay|squashfs|ramfs|devtmpfs"} / node_filesystem_size_bytes < 0.15
                for: 10m
                annotations:
                  summary: "Low disk space on {{ $labels.mountpoint }}"
                  description: "Only {{ $value | humanizePercentage }} free on {{ $labels.device }}."
          - name: zfs
            rules:
              - alert: ZFSPoolNotHealthy
                expr: zfs_pool_health != 0
                for: 5m
                annotations:
                  summary: "ZFS pool {{ $labels.pool }} unhealthy"
                  description: "Pool health code {{ $value }} (0 = ONLINE)."
          - name: systemd
            rules:
              - alert: SystemdUnitFailed
                expr: node_systemd_unit_state{state="failed"} == 1
                for: 2m
                annotations:
                  summary: "Systemd unit {{ $labels.name }} failed"
                  description: "Unit has been in failed state for 2m."
          - name: nginx
            rules:
              - alert: NginxDown
                expr: nginx_up == 0
                for: 5m
                annotations:
                  summary: "nginx exporter cannot reach nginx"
          - name: postgres
            rules:
              - alert: PostgresDown
                expr: pg_up == 0
                for: 5m
                annotations:
                  summary: "postgres exporter cannot reach postgres"
              - alert: PostgresTooManyConnections
                expr: sum by (instance) (pg_stat_activity_count) / on (instance) pg_settings_max_connections > 0.8
                for: 10m
                annotations:
                  summary: "Postgres connection saturation > 80% on {{ $labels.instance }}"
      ''
    ];
  };

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
