{ config, ... }:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = false; # Only expose web UI over tailscale
  };

  users.users.qbittorrent = {
    uid = 352;
    extraGroups = [
      "users"
      "media"
    ];
  };

  # Allow web UI access only via the tailscale interface (port 8080)
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8080 ];

  # Kill switch: qbittorrent (UID 352) may only send traffic through
  # mullvad0 or loopback. Any other outbound interface is dropped,
  # preventing leaks if the Mullvad tunnel is down.
  networking.nftables.enable = true;
  networking.nftables.tables.qbittorrent-killswitch = {
    family = "inet";
    content = ''
      chain qbittorrent-killswitch {
        type filter hook output priority 0; policy accept;
        skuid ${toString config.users.users.qbittorrent.uid} oifname { "mullvad0", "lo" } accept;
        skuid ${toString config.users.users.qbittorrent.uid} drop;
      }
    '';
  };
}
