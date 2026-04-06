{ ... }:
{
  services.qbittorrent = {
    enable = true;
    dataDir = "/tank/qbittorrent";
    openFirewall = false; # Only expose web UI over tailscale
  };

  users.users.qbittorrent.extraGroups = [ "users" ];

  # Allow web UI access only via the tailscale interface (port 8080)
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8080 ];

  # Kill switch: drop any outbound traffic from the qbittorrent user
  # that is not going through tailscale or loopback
  networking.nftables.enable = true;
  networking.nftables.tables.qbittorrent-killswitch = {
    family = "inet";
    content = ''
      chain qbittorrent-killswitch {
        type filter hook output priority 0; policy accept;
        skuid "qbittorrent" oifname != { "lo", "tailscale0" } drop;
      }
    '';
  };
}
