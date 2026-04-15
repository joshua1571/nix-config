{ pkgs }:
{
  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/home/jrh/Share" = {
    device = "//server/tank/personal";
    fsType = "cifs";
    options =
      let

        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,uid=1000,gid=100,iocharset=utf8,x-systemd.requires=tailscaled.service";

      in
      [ "${automount_opts},credentials=/home/jrh/.samba/credentials" ];
  };
}
