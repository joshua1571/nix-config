{ config, ... }:
{
  age.secrets.mullvad-wg-private-key = {
    file = ../../secrets/mullvad-wg-private-key.age;
  };

  age.secrets.mullvad-wg-preshared-key = {
    file = ../../secrets/mullvad-wg-preshared-key.age;
  };

  # Raw WireGuard interface for Mullvad — no default route set here.
  # Only qbittorrent traffic is routed through this tunnel (see postSetup).
  networking.wireguard.interfaces.mullvad0 = {
    # Your Mullvad-assigned tunnel address — from the [Interface] Address field
    ips = [ "10.136.102.81/32" ];

    privateKeyFile = config.age.secrets.mullvad-wg-private-key.path;

    peers = [
      {
        # From the [Peer] section of the Mullvad WireGuard config
        publicKey = "SDnciTlujuy2APFTkhzfq5X+LDi+lhfU38wI2HBCxxs=";
        endpoint = "169.150.203.15:18970";
        presharedKeyFile = config.age.secrets.mullvad-wg-preshared-key.path;
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        persistentKeepalive = 25;
      }
    ];

    # Route qbittorrent (UID 352) through this interface via policy routing.
    # Table 200 holds a default route via mullvad0; the ip rule steers
    # qbittorrent packets into that table before the main table is consulted.
    postSetup = ''
      ip route add default dev mullvad0 table 200
      ip rule add uidrange 352-352 lookup 200 priority 100
    '';

    preShutdown = ''
      ip rule del uidrange 352-352 lookup 200 priority 100 || true
      ip route del default dev mullvad0 table 200 || true
    '';
  };
}
