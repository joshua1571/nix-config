{ pkgs, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "16c86c23";

  services.zfs = {
    autoScrub = {
      enable = true;
      pools = [
        "tank"
        "fasttank"
      ];
    };
    autoSnapshot = {
      enable = true; # Note that you must set the com.sun:auto-snapshot property to true on all datasets which you wish to auto-snapshot
      frequent = 0;
      flags = "-k -p --utc";
    };
    autoReplication.enable = false; # Placeholder for when I setup another ZFS host in the future
  };

  environment.systemPackages = with pkgs; [
    zfs
    smartmontools
  ];
}
