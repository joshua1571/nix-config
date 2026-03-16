{
  ...
}:

{
  imports = [
    # Common
    ../../modules/nixos/common.nix
    ../../modules/nixos/gnupg.nix
    ../../modules/nixos/openssh_server.nix

    # Server
    ../../modules/nixos/zfs.nix

    # Self Hosted Services
    ../../modules/nixos/homepage-dashboard.nix
    ../../modules/nixos/jellyfin.nix
    ../../modules/nixos/navidrome.nix
    ../../modules/nixos/immich.nix

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
