let
  # Host SSH keys — used by agenix to decrypt secrets at boot on each machine.
  # Get with: cat /etc/ssh/ssh_host_ed25519_key.pub
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7imJUouKlgYe0BVbpZ1lwHtmulNDsl78yg1oUBQyRj";
  # Personal SSH key — used to encrypt/edit secrets from your workstation.
  # Get with: cat ~/.ssh/id_jrh.pub
  jrh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiRLsg3qCuqZDOa9NRhagjAzkSy2P5bGaDgN2+R4eZl";

  serverOnly = [
    server
    jrh
  ];
in
{
  "secrets/tailscale-hostname.age".publicKeys = serverOnly;
  "secrets/tailscale-domain.age".publicKeys = serverOnly;
  "secrets/nextcloud-adminpass.age".publicKeys = serverOnly;
  "secrets/freshrss-password.age".publicKeys = serverOnly;
  "secrets/mullvad-wg-private-key.age".publicKeys = serverOnly;
  "secrets/mullvad-wg-preshared-key.age".publicKeys = serverOnly;

  # Homepage-dashboard widget credentials
  "secrets/homepage-jellyfin-key.age".publicKeys = serverOnly;
  "secrets/homepage-jellyseerr-key.age".publicKeys = serverOnly;
  "secrets/homepage-immich-key.age".publicKeys = serverOnly;
  "secrets/homepage-radarr-key.age".publicKeys = serverOnly;
  "secrets/homepage-sonarr-key.age".publicKeys = serverOnly;
  "secrets/homepage-lidarr-key.age".publicKeys = serverOnly;
  "secrets/homepage-prowlarr-key.age".publicKeys = serverOnly;
  "secrets/homepage-navidrome-user.age".publicKeys = serverOnly;
  "secrets/homepage-navidrome-salt.age".publicKeys = serverOnly;
  "secrets/homepage-navidrome-token.age".publicKeys = serverOnly;
  "secrets/homepage-homeassistant-key.age".publicKeys = serverOnly;
  "secrets/homepage-freshrss-password.age".publicKeys = serverOnly;

  # Grafana admin password (read by grafana at startup via $__file{...}).
  "secrets/grafana-admin-password.age".publicKeys = serverOnly;

  # LLDAP — assembled into /run/lldap-env at boot (see lldap.nix).
  "secrets/lldap-jwt-secret.age".publicKeys = serverOnly;
  "secrets/lldap-key-seed.age".publicKeys = serverOnly;
  "secrets/lldap-admin-password.age".publicKeys = serverOnly;

  # Authelia core secrets (see authelia.nix).
  "secrets/authelia-jwt-secret.age".publicKeys = serverOnly;
  "secrets/authelia-storage-encryption-key.age".publicKeys = serverOnly;
  "secrets/authelia-lldap-bind-password.age".publicKeys = serverOnly;

  # Authelia OIDC issuer secrets (see authelia.nix — identity_providers.oidc).
  "secrets/authelia-oidc-hmac-secret.age".publicKeys = serverOnly;
  "secrets/authelia-oidc-jwks-key.age".publicKeys = serverOnly;

  # Grafana OIDC — plaintext used by grafana, PHC hash used by authelia.
  "secrets/grafana-oidc-client-secret.age".publicKeys = serverOnly;
  "secrets/authelia-oidc-client-grafana-hash.age".publicKeys = serverOnly;

  # Immich OIDC — Immich stores the plaintext client secret in its DB
  # (configured via its admin UI), so no plaintext lives in agenix. Only
  # Authelia's PHC hash needs to be here.
  "secrets/authelia-oidc-client-immich-hash.age".publicKeys = serverOnly;

  # Nextcloud OIDC — same pattern as Immich: plaintext pasted into the
  # user_oidc admin UI, only the PHC hash needs to live in agenix.
  "secrets/authelia-oidc-client-nextcloud-hash.age".publicKeys = serverOnly;

  # Jellyfin OIDC — plaintext pasted into the SSO-Auth plugin config in
  # Jellyfin UI, only the PHC hash lives here.
  "secrets/authelia-oidc-client-jellyfin-hash.age".publicKeys = serverOnly;
}
