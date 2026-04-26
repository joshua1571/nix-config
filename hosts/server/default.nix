{
  ...
}:

{
  imports = [
    # Secrets
    ../../modules/nixos/agenix.nix

    # Common
    ../../modules/nixos/common.nix
    ../../modules/nixos/gnupg.nix
    ../../modules/nixos/openssh_server.nix

    # Server
    ../../modules/nixos/zfs.nix
    ../../modules/nixos/smb_share_server.nix
    ../../modules/nixos/mullvad.nix

    # Reverse Proxy
    ../../modules/nixos/nginx.nix

    # Self Hosted Services
    ../../modules/nixos/homepage-dashboard.nix
    ../../modules/nixos/jellyfin.nix
    ../../modules/nixos/navidrome.nix
    ../../modules/nixos/immich.nix
    ../../modules/nixos/radarr.nix
    ../../modules/nixos/sonarr.nix
    ../../modules/nixos/qbittorrent.nix
    ../../modules/nixos/prowlarr.nix
    ../../modules/nixos/lidarr.nix
    ../../modules/nixos/jellyseerr.nix
    ../../modules/nixos/flaresolverr.nix

    # Storage layout
    ./storage.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "server";
    networkmanager.enable = true;
  };

  hardware.graphics.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
