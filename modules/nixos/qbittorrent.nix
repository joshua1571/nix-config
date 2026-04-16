{ config, ... }:
let
  uid = toString config.users.users.qbittorrent.uid;
in
{
  services.qbittorrent = {
    enable = true;
    openFirewall = false;
  };

  users.users.qbittorrent = {
    uid = 352;
    extraGroups = [
      "users"
      "media"
    ];
  };

  networking.nftables.enable = true;

  # Mark new outbound connections from qbittorrent with fwmark 0x200 so
  # they get routed through mullvad0 via policy routing (see mullvad.nix).
  # Only NEW connections are marked — ct state established here means the
  # connection was initiated by a remote client (e.g. web UI from browser),
  # so those responses are left unmarked and use normal LAN/Tailscale routing.
  networking.nftables.tables.qbittorrent-routing = {
    family = "inet";
    content = ''
      chain output {
        type route hook output priority mangle; policy accept;
        skuid ${uid} ct state new ct mark set 0x200 meta mark set 0x200;
        skuid ${uid} ct mark 0x200 meta mark set 0x200;
      }
    '';
  };

  # Kill switch: allow established connections (web UI responses over LAN/Tailscale)
  # and mullvad tunnel traffic. Drop everything else from qbittorrent so torrent
  # traffic cannot leak to LAN if the Mullvad tunnel is down.
  networking.nftables.tables.qbittorrent-killswitch = {
    family = "inet";
    content = ''
      chain output {
        type filter hook output priority 0; policy accept;
        skuid ${uid} ct state established,related accept;
        skuid ${uid} oifname { "mullvad0", "lo" } accept;
        skuid ${uid} drop;
      }
    '';
  };
}
