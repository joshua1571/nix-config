{
  pkgs,
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

    # Graphical Client
    ../../modules/nixos/kde.nix
    ../../modules/nixos/smb_share_client.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    #extraModprobeConfig = ''
    #  options mt7921e disable_aspm=1
    #'';
    initrd.systemd.tpm2.enable = false;
  };

  networking = {
    hostName = "htpc";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VA-API (iHD) userspace
        vpl-gpu-rt # oneVPL (QSV) runtime
      ];
    };
  };

  services.xserver.videoDrivers = [ "modesetting" ];

  services.libinput.enable = true; # enable touchpad

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
