{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/kde.nix
    ../../modules/nixos/gnupg.nix
    ../../modules/nixos/openssh.nix
    #../../modules/nixos/smb_share.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/games_disk.nix
    #../../modules/nixos/openrgb.nix
    # TODO: GPU Acceleration https://hydra.nixos.org/build/124333142/download/2/nixos/index.html#sec-gpu-accel

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModprobeConfig = ''
      options mt7921e disable_aspm=1
    '';
  };

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
    firewall.checkReversePath = "loose"; # tailscale dns fix
  };

  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
