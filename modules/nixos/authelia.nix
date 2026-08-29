{ config, ... }:
let
  runtimeConfig = "/run/authelia-main/domain-config.yaml";
in
{
  # tailscale-hostname is also declared in nginx.nix. Duplicate attrs merge
  # cleanly under NixOS's age.secrets option.
  age.secrets =
    let
      autheliaOwned = file: {
        inherit file;
        owner = "authelia-main";
        mode = "0400";
      };
      serverOwned = file: {
        inherit file;
        owner = "root";
        mode = "0400";
      };
    in
    {
      authelia-jwt-secret = autheliaOwned ../../secrets/authelia-jwt-secret.age;
      authelia-storage-encryption-key = autheliaOwned ../../secrets/authelia-storage-encryption-key.age;
      authelia-lldap-bind-password = autheliaOwned ../../secrets/authelia-lldap-bind-password.age;
      authelia-oidc-hmac-secret = autheliaOwned ../../secrets/authelia-oidc-hmac-secret.age;
      authelia-oidc-jwks-key = autheliaOwned ../../secrets/authelia-oidc-jwks-key.age;
      authelia-oidc-client-grafana-hash = autheliaOwned ../../secrets/authelia-oidc-client-grafana-hash.age;
      authelia-oidc-client-immich-hash = autheliaOwned ../../secrets/authelia-oidc-client-immich-hash.age;
      authelia-oidc-client-nextcloud-hash = autheliaOwned ../../secrets/authelia-oidc-client-nextcloud-hash.age;
      authelia-oidc-client-jellyfin-hash = autheliaOwned ../../secrets/authelia-oidc-client-jellyfin-hash.age;
      # Also declared in nginx.nix / grafana.nix as root-owned. Duplicate
      # decl under an authelia-scoped name (same source .age file) so
      # Authelia's OIDC config templating (runs as authelia-main) can read
      # the FQDN when substituting redirect_uris.
      authelia-tailscale-hostname = autheliaOwned ../../secrets/tailscale-hostname.age;
      tailscale-hostname = serverOwned ../../secrets/tailscale-hostname.age;
    };

  # Assemble the session-cookie block at boot from the runtime Tailscale
  # FQDN. Authelia validates cookie domains (must have a period or be an
  # IP) and requires HTTPS URLs — a placeholder can't satisfy both, so
  # the config has to be composed at activation time from the real hostname.
  systemd.services.authelia-runtime-config = {
    description = "Assemble Authelia runtime cookie-domain config";
    after = [ "agenix.service" ];
    before = [ "authelia-main.service" ];
    wantedBy = [ "authelia-main.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "authelia-main";
      RuntimeDirectoryMode = "0755";
      RuntimeDirectoryPreserve = "yes";
    };
    script = ''
      umask 022
      fqdn=$(cat ${config.age.secrets.tailscale-hostname.path})
      cat > ${runtimeConfig} <<EOF
      session:
        cookies:
          - domain: "$fqdn"
            authelia_url: "https://$fqdn/authelia/"
            default_redirection_url: "https://$fqdn/"
      EOF
      chmod 0444 ${runtimeConfig}
    '';
  };

  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
      storageEncryptionKeyFile = config.age.secrets.authelia-storage-encryption-key.path;
      # OIDC issuer keys. The module templates jwks[0].key from the PEM
      # file and sets AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE.
      oidcHmacSecretFile = config.age.secrets.authelia-oidc-hmac-secret.path;
      oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-jwks-key.path;
    };

    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
        config.age.secrets.authelia-lldap-bind-password.path;
    };

    # Cookie/session block composed at runtime (see oneshot above).
    settingsFiles = [ runtimeConfig ];

    settings = {
      theme = "auto";
      default_2fa_method = "totp";
      log.level = "info";

      # Loopback + subpath. nginx proxies /authelia/ to http://127.0.0.1:9091
      # (no trailing slash) so the /authelia prefix reaches Authelia intact.
      server.address = "tcp://127.0.0.1:9091/authelia";

      authentication_backend = {
        # Strict-readonly bind can't perform resets. Users reset their
        # own password via the LLDAP UI (behind Authelia in Phase 3+).
        password_reset.disable = true;
        refresh_interval = "5m";
        ldap = {
          implementation = "lldap";
          address = "ldap://127.0.0.1:3890";
          timeout = "5s";
          start_tls = false;
          base_dn = "dc=homelab,dc=local";
          # Dedicated read-only bind. Create the user in the LLDAP UI and
          # add to the `lldap_strict_readonly` group. Password lives in
          # authelia-lldap-bind-password.age.
          user = "uid=authelia_bind,ou=people,dc=homelab,dc=local";
          additional_users_dn = "ou=people";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "ou=groups";
          groups_filter = "(member={dn})";
          attributes = {
            username = "uid";
            group_name = "cn";
            mail = "mail";
            display_name = "displayName";
          };
        };
      };

      # SQLite is fine at homelab scale and avoids Postgres peer-auth
      # complications with the module's PrivateUsers sandbox. StateDirectory
      # is /var/lib/authelia-main (created by systemd, owned by
      # authelia-main:authelia-main, mode 0700).
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";

      # Password resets etc. write to a file — no SMTP dependency yet.
      # Read via `journalctl -u authelia-main` or the file directly.
      notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";

      session = {
        name = "authelia_session";
        same_site = "lax";
        inactivity = "5m";
        expiration = "1h";
        remember_me = "1M";
        # `cookies` list is provided by settingsFiles at runtime.
      };

      # Phase 2: permissive default so nothing is gated yet. Phase 3
      # replaces this with tiered rules once nginx forward-auth is wired.
      access_control = {
        default_policy = "one_factor";
        rules = [ ];
      };

      regulation = {
        max_retries = 5;
        find_time = "2m";
        ban_time = "10m";
      };

      # OIDC issuer. jwks[0].key is provided at runtime by the module from
      # oidcIssuerPrivateKeyFile above. Client secrets and the FQDN in
      # redirect URIs are read at startup via Authelia's `{{ secret ... }}`
      # config-template filter (enabled by X_AUTHELIA_CONFIG_FILTERS=template,
      # which the module sets when oidcIssuerPrivateKeyFile is non-null).
      identity_providers.oidc = {
        cors.endpoints = [
          "authorization"
          "token"
          "revocation"
          "introspection"
        ];
        clients = [
          {
            client_id = "grafana";
            client_name = "Grafana";
            client_secret = ''{{ secret "${config.age.secrets.authelia-oidc-client-grafana-hash.path}" }}'';
            public = false;
            authorization_policy = "one_factor";
            require_pkce = false;
            redirect_uris = [
              ''https://{{ secret "${config.age.secrets.authelia-tailscale-hostname.path}" }}/grafana/login/generic_oauth''
            ];
            scopes = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_post";
          }
          {
            client_id = "immich";
            client_name = "Immich";
            client_secret = ''{{ secret "${config.age.secrets.authelia-oidc-client-immich-hash.path}" }}'';
            public = false;
            authorization_policy = "one_factor";
            require_pkce = false;
            # Immich runs at root on its own HTTPS listener (:2443) because
            # it doesn't support subpath serving. The mobile-app callback
            # uses a custom URL scheme.
            redirect_uris = [
              ''https://{{ secret "${config.age.secrets.authelia-tailscale-hostname.path}" }}:2443/auth/login''
              ''https://{{ secret "${config.age.secrets.authelia-tailscale-hostname.path}" }}:2443/user-settings''
              "app.immich:/"
            ];
            scopes = [
              "openid"
              "profile"
              "email"
            ];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_post";
          }
          {
            client_id = "nextcloud";
            client_name = "Nextcloud";
            client_secret = ''{{ secret "${config.age.secrets.authelia-oidc-client-nextcloud-hash.path}" }}'';
            public = false;
            authorization_policy = "one_factor";
            require_pkce = false;
            redirect_uris = [
              ''https://{{ secret "${config.age.secrets.authelia-tailscale-hostname.path}" }}/nextcloud/apps/user_oidc/code''
            ];
            # `groups` is required because user_oidc unconditionally requests
            # the `groups` claim, and Authelia rejects claim requests whose
            # scope isn't in the client's registration.
            scopes = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_post";
          }
          {
            client_id = "jellyfin";
            client_name = "Jellyfin";
            client_secret = ''{{ secret "${config.age.secrets.authelia-oidc-client-jellyfin-hash.path}" }}'';
            public = false;
            authorization_policy = "one_factor";
            require_pkce = false;
            # The SSO-Auth plugin's redirect path uses the provider name
            # you set in its UI — we use "authelia" below in the setup.
            redirect_uris = [
              ''https://{{ secret "${config.age.secrets.authelia-tailscale-hostname.path}" }}/jellyfin/sso/OID/redirect/authelia''
            ];
            scopes = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_post";
          }
        ];
      };
    };
  };
}
