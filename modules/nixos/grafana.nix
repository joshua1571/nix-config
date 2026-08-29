{ config, pkgs, ... }:
let
  # Node Exporter Full — the standard host-metrics dashboard. Fetched at
  # build time; the datasource placeholder (${DS_PROMETHEUS}) is rewritten
  # to match the provisioned datasource name below so no manual selection
  # is needed on first load.
  nodeExporterFullRaw = pkgs.fetchurl {
    url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
    hash = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
  };
  nodeExporterFull = pkgs.runCommand "node-exporter-full.json" { } ''
    ${pkgs.gnused}/bin/sed 's|\''${DS_PROMETHEUS}|Prometheus|g' ${nodeExporterFullRaw} > $out
  '';
in
{
  age.secrets.grafana-admin-password = {
    file = ../../secrets/grafana-admin-password.age;
    owner = "grafana";
    mode = "0400";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
      };
      security = {
        admin_user = "admin";
        # $__file{path} tells grafana to read the value from a file at
        # startup, so the secret never lands in the nix store or config.
        admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "default";
          options.path = pkgs.linkFarm "grafana-dashboards" [
            {
              name = "node-exporter-full.json";
              path = nodeExporterFull;
            }
          ];
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
