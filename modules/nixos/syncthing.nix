{ username, ... }:
{
  services.syncthing = {
    enable = true;
    user = username;
    # dataDir is where synced folders live; configDir defaults to dataDir/.config/syncthing
    dataDir = "/home/${username}";
    openDefaultPorts = true; # 22000/TCP+UDP (sync), 21027/UDP (discovery)
  };

  # Web UI on 8384 — restrict to tailscale in nginx if needed
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8384 ];
}
