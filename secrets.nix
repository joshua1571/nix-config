let
  # Server SSH host key — used by agenix to decrypt secrets at boot.
  # Get it with: ssh-keyscan -t ed25519 <server-ip> | awk '{print $2, $3}'
  # Or on the server: cat /etc/ssh/ssh_host_ed25519_key.pub
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7imJUouKlgYe0BVbpZ1lwHtmulNDsl78yg1oUBQyRj";

  # Your personal age public key — used to encrypt secrets from your machine.
  # Generate with: age-keygen -o ~/.age/key.txt  (then cat ~/.age/key.txt for the pubkey)
  # Or convert your SSH key: ssh-to-age < ~/.ssh/id_ed25519.pub
  jrh = "age1s0q04ug6ktdyqcadmzm6enjuhz6k92ern07rxe2yd365a95qfudslpckhm";

  allKeys = [
    server
    jrh
  ];
in
{
  "secrets/tailscale-hostname.age".publicKeys = allKeys;
}
