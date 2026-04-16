{ config, pkgs, ... }:
{
  age.secrets.mullvad-wg-private-key = {
    file = ../../secrets/mullvad-wg-private-key.age;
  };

  age.secrets.mullvad-wg-preshared-key = {
    file = ../../secrets/mullvad-wg-preshared-key.age;
  };

  # systemd-resolved is required for the dns option below to take effect.
  # It also makes /etc/resolv.conf point to 127.0.0.53, so all processes
  # (including qbittorrent) query resolved on lo rather than an external
  # server directly — lo is whitelisted in the kill switch.
  services.resolved.enable = true;

  # Raw WireGuard interface for Mullvad — no default route set here.
  # Only qbittorrent traffic is routed through this tunnel (see postSetup).
  networking.wireguard.interfaces.mullvad0 = {
    # Your Mullvad-assigned tunnel address — from the [Interface] Address field
    ips = [ "10.136.102.81/32" ];

    # Use Mullvad's in-tunnel DNS. resolved picks this up via resolvconf
    # and queries it through the host route added in postSetup below.
    dns = [ "10.64.0.1" ];

    privateKeyFile = config.age.secrets.mullvad-wg-private-key.path;

    # No declarative peers — configuring the peer manually in postSetup
    # via `wg set` avoids NixOS generating a peer systemd service that
    # would add allowedIPs routes to the main routing table.

    postSetup = ''
      # Add the Mullvad peer directly. allowedIPs here is WireGuard's
      # cryptographic routing (any packet sent to mullvad0 is encrypted
      # and forwarded to this peer), but no kernel routes are added.
      ${pkgs.wireguard-tools}/bin/wg set mullvad0 \
        peer "SDnciTlujuy2APFTkhzfq5X+LDi+lhfU38wI2HBCxxs=" \
        preshared-key ${config.age.secrets.mullvad-wg-preshared-key.path} \
        endpoint "169.150.203.15:18970" \
        allowed-ips "0.0.0.0/0,::/0" \
        persistent-keepalive 25

      # Add default route only in table 200 — used exclusively for
      # fwmark-tagged qbittorrent traffic, not for normal system traffic.
      ip route add default dev mullvad0 table 200
      ip rule add fwmark 0x200 lookup 200 priority 100

      # Add a host route to Mullvad's DNS in the main table so
      # systemd-resolved can reach it (resolved runs as its own UID,
      # not kill-switched, and uses normal routing).
      ip route add 10.64.0.1 dev mullvad0
    '';

    preShutdown = ''
      ip rule del fwmark 0x200 lookup 200 priority 100 || true
      ip route del default dev mullvad0 table 200 || true
      ip route del 10.64.0.1 dev mullvad0 || true
    '';
  };
}
