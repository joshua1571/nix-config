# sudo nixos-rebuild switch --flake /home/jrh/Development/GitHub/nix-config

# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix = {
    gc.automatic = true;
    gc.dates = "04:00";
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModprobeConfig = ''
      options mt7921e disable_aspm=1
    '';
  };

  networking = {
    hostName = "nixos"; # Define hostname
    networkmanager.enable = true;
    firewall.checkReversePath = "loose"; # tailscale dns fix
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  fileSystems."/home/jrh/Share" = {
    device =
      "//storage-ts/share"; # Need tailscale to be running on storage for mount to work properly, storage-ts won't reply
    fsType = "cifs";
    options = let

      automount_opts =
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,uid=1000,gid=100,iocharset=utf8,x-systemd.requires=tailscaled.service";

    in [ "${automount_opts},credentials=/home/jrh/.samba/credentials" ];
  };

  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  ###############################################################################
  ### Services
  ###############################################################################
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    libinput.enable = true;
    tailscale.enable = true;

    opensnitch.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;

    # KDE Plasma Desktop Environment
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
  };
  environment.plasma6.excludePackages = [ pkgs.kdePackages.elisa ];

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;
    packages = with pkgs; [
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix
      nerd-fonts.sauce-code-pro
      nerd-fonts.hack
      fira-code # for use with wezterm
    ];
  };

  ###############################################################################
  ### User (managed by home-manager)
  ###############################################################################
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jrh = {
    isNormalUser = true;
    description = "Joshua Hernandez";
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  ###############################################################################
  ### System Programs
  ###############################################################################
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lm_sensors
    cifs-utils
    file
    pciutils
    usbutils
  ];

  programs.partition-manager.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  ###programs.mtr.enable = true;

  # Automatic upgrades
  #system.autoUpgrade.enable = true;
  #system.autoUpgrade.allowReboot = false;

  ### System
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # NOT SUPPORTED WITH FLAKES
  #system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
