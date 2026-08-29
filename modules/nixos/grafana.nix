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
  age.secrets = {
    grafana-admin-password = {
      file = ../../secrets/grafana-admin-password.age;
      owner = "grafana";
      mode = "0400";
    };
    # Read only by the grafana-env oneshot (as root); grafana itself sees
    # the value as GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET via env.
    grafana-oidc-client-secret = {
      file = ../../secrets/grafana-oidc-client-secret.age;
      owner = "root";
      mode = "0400";
    };
    # Duplicate decl (also in nginx.nix / authelia.nix) — merges cleanly.
    tailscale-hostname = {
      file = ../../secrets/tailscale-hostname.age;
      owner = "root";
      mode = "0400";
    };
  };

  # Assemble a runtime env file that pins Grafana's public URL to the
  # tailscale FQDN and injects the OIDC client secret + endpoints.
  # These settings can't be baked in at build time because the FQDN lives
  # in an agenix secret.
  systemd.services.grafana-env = {
    description = "Assemble Grafana runtime env from agenix secrets";
    after = [ "agenix.service" ];
    before = [ "grafana.service" ];
    wantedBy = [ "grafana.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      umask 077
      fqdn=$(cat ${config.age.secrets.tailscale-hostname.path})
      clientSecret=$(cat ${config.age.secrets.grafana-oidc-client-secret.path})
      {
        echo "GF_SERVER_DOMAIN=$fqdn"
        echo "GF_SERVER_ROOT_URL=https://$fqdn/grafana/"
        echo "GF_SERVER_SERVE_FROM_SUB_PATH=true"
        echo "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=$clientSecret"
        echo "GF_AUTH_GENERIC_OAUTH_AUTH_URL=https://$fqdn/authelia/api/oidc/authorization"
        echo "GF_AUTH_GENERIC_OAUTH_TOKEN_URL=https://$fqdn/authelia/api/oidc/token"
        echo "GF_AUTH_GENERIC_OAUTH_API_URL=https://$fqdn/authelia/api/oidc/userinfo"
      } > /run/grafana-env
      chmod 0400 /run/grafana-env
    '';
  };

  systemd.services.grafana.serviceConfig.EnvironmentFile = "/run/grafana-env";

  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Loopback-only; reached via nginx at /grafana/ behind Authelia OIDC.
        # domain, root_url, serve_from_sub_path come from GF_SERVER_* env.
        http_addr = "127.0.0.1";
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

      # OIDC via Authelia. Endpoints + client_secret injected at runtime
      # via GF_AUTH_GENERIC_OAUTH_* env vars from /run/grafana-env.
      # role_attribute_path maps LLDAP group membership to Grafana roles.
      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        icon = "signin";
        allow_sign_up = true;
        auto_login = false;
        client_id = "grafana";
        scopes = "openid profile email groups";
        login_attribute_path = "preferred_username";
        name_attribute_path = "name";
        email_attribute_path = "email";
        role_attribute_path = "contains(groups[*], 'admins') && 'Admin' || 'Viewer'";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          # Matches prometheus --web.route-prefix=/prometheus.
          url = "http://127.0.0.1:9090/prometheus";
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
}
