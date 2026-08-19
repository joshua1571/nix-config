{
  pkgs,
  ...
}:

{
  imports = [
    # Secrets
    ../../modules/nixos/agenix.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/gnupg.nix
    ../../modules/nixos/openssh_server.nix
    #../../modules/nixos/mullvad_client.nix #This uses options that are unavailable in nixpkgs stable
    ../../modules/nixos/kde.nix
    #../../modules/nixos/local_ai_server.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/games_disk.nix
    ../../modules/nixos/obs-studio.nix
    #../../modules/nixos/smb_share_client.nix #This uses options that are unavailable in nixpkgs stable
    ../../modules/nixos/openrgb.nix
    ../../modules/nixos/keychron.nix
    ../../modules/nixos/email.nix
    ../../modules/nixos/development_environment.nix
    ../../modules/nixos/podman.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModprobeConfig = ''
      options mt7921e disable_aspm=1
    '';
  };

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

  # OpenRGB AMD motherboard
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
