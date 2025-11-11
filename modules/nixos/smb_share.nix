{ pkgs, ... }: {
  fileSystems."/home/jrh/Share" = {
    device =
      "//storage-ts/share"; # Need tailscale to be running on storage for mount to work properly, storage-ts won't reply
    fsType = "cifs";
    options = let

      automount_opts =
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,uid=1000,gid=100,iocharset=utf8,x-systemd.requires=tailscaled.service";

    in [ "${automount_opts},credentials=/home/jrh/.samba/credentials" ];
  };
}
