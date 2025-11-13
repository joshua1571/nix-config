{ pkgs, username, ... }: {

  environment.systemPackages = with pkgs; [ btrfs-progs ];

  fileSystems."/home/${username}/Games" = {
    device = "/dev/disk/by-uuid/7af7a8d4-885a-4a06-a586-fb244fc62dba";
    fsType = "btrfs";
    options = [ "rw" "relatime" "ssd" "discard=async" "space_cache=v2" ];
    neededForBoot = false;
  };

}
