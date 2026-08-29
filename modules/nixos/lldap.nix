{ config, lib, ... }:
{
  # Static user so agenix can chown secrets to lldap directly. The upstream
  # module defaults to DynamicUser=true, which allocates a fresh UID each
  # start and makes per-file ownership impossible.
  users.users.lldap = {
    isSystemUser = true;
    group = "lldap";
  };
  users.groups.lldap = { };

  age.secrets =
    let
      lldapOwned = file: {
        inherit file;
        owner = "lldap";
        mode = "0400";
      };
    in
    {
      lldap-jwt-secret = lldapOwned ../../secrets/lldap-jwt-secret.age;
      lldap-key-seed = lldapOwned ../../secrets/lldap-key-seed.age;
      lldap-admin-password = lldapOwned ../../secrets/lldap-admin-password.age;
    };

  services.lldap = {
    enable = true;

    # LLDAP uses figment_file_provider_adapter, so any config key accepts a
    # `_FILE` env override that reads the file contents at startup.
    environment = {
      LLDAP_JWT_SECRET_FILE = config.age.secrets.lldap-jwt-secret.path;
      LLDAP_KEY_SEED_FILE = config.age.secrets.lldap-key-seed.path;
      LLDAP_LDAP_USER_PASS_FILE = config.age.secrets.lldap-admin-password.path;
    };

    settings = {
      # Base for all DNs in the tree. Match this in Authelia's LDAP config.
      ldap_base_dn = "dc=homelab,dc=local";

      # Loopback only — Authelia runs on the same host and no other machine
      # should reach LDAP directly. The admin web UI is exposed later via
      # nginx behind Authelia (admin group only).
      ldap_host = "127.0.0.1";
      http_host = "127.0.0.1";
      http_url = "http://127.0.0.1:17170";

      ldap_user_dn = "admin";
      ldap_user_email = "admin@homelab.local";
    };

    silenceForceUserPassResetWarning = true;
  };

  systemd.services.lldap.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "lldap";
    Group = "lldap";
  };
}
