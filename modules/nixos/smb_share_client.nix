{
  pkgs,
  username,
  ...
}:
{
  environment.systemPackages = [ pkgs.cifs-utils ];

  security.wrappers."mount.cifs" = {
    source = "${pkgs.cifs-utils.bin}/bin/mount.cifs";
    owner = "root";
    group = "root";
    setuid = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/${username}/Share		0755 ${username} users -"
  ];

  fileSystems."/home/${username}/Share" = {
    device = "//server/Share";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,uid=1000,gid=100,iocharset=utf8,x-systemd.requires=tailscaled.service";
      in
      [ "${automount_opts},credentials=/home/${username}/.samba/credentials" ];
  };
}
