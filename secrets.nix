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
  "secrets/mullvad-wg-private-key.age".publicKeys = serverOnly;
  "secrets/mullvad-wg-preshared-key.age".publicKeys = serverOnly;
}
