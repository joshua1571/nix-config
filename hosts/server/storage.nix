{ username, ... }:

{
  boot.zfs.extraPools = [
    "tank"
    "fasttank"
  ];

  # /tank/personal/** — same-owner as /tank, tmpfiles works fine here.
  systemd.tmpfiles.rules = [
    "d /tank/personal/photos                0755 ${username} users -"
    "d /tank/personal/photos/immich_data    0755 ${username} users -"
    "d /tank/personal/documents             0755 ${username} users -"
    "d /tank/personal/downloads             0755 ${username} users -"
    "d /tank/personal/development           0755 ${username} users -"
  ];

  # /tank/media/** — set up via a oneshot ordered after zfs-mount.service.
  # systemd-tmpfiles runs at sysinit.target (before zfs-mount), so any
  # tmpfiles rules under /tank/media/** race with the ZFS mount and end
  # up applied to the underlying directory rather than the mounted dataset.
  # It also trips tmpfiles' unsafe-path-transition check inconsistently.
  # A oneshot with RequiresMountsFor makes ordering deterministic and
  # bypasses the tmpfiles safety checks entirely.
  systemd.services.media-perms = {
    description = "Set ownership and mode on /tank/media tree";
    wantedBy = [ "multi-user.target" ];
    after = [ "zfs-mount.service" ];
    unitConfig.RequiresMountsFor = [ "/tank/media" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu

      apply() {
        mode="$1"; owner="$2"; group="$3"; dir="$4"
        mkdir -p "$dir"
        chown "$owner:$group" "$dir"
        chmod "$mode" "$dir"
      }

      apply 0775 ${username}   users   /tank/media

      apply 0775 qbittorrent   media   /tank/media/torrents
      apply 0775 qbittorrent   media   /tank/media/torrents/books
      apply 0775 qbittorrent   media   /tank/media/torrents/games
      apply 0775 qbittorrent   media   /tank/media/torrents/movies
      apply 0775 qbittorrent   media   /tank/media/torrents/music
      apply 0775 qbittorrent   media   /tank/media/torrents/tv

      apply 0755 ${username}   users   /tank/media/usenet
      apply 0755 ${username}   users   /tank/media/usenet/incomplete
      apply 0755 ${username}   users   /tank/media/usenet/complete
      apply 0755 ${username}   users   /tank/media/usenet/complete/books
      apply 0755 ${username}   users   /tank/media/usenet/complete/movies
      apply 0755 ${username}   users   /tank/media/usenet/complete/music
      apply 0755 ${username}   users   /tank/media/usenet/complete/tv
      apply 0755 ${username}   users   /tank/media/usenet/complete/games

      apply 0755 ${username}   users   /tank/media/books
      apply 0755 radarr        radarr  /tank/media/movies
      apply 0755 lidarr        lidarr  /tank/media/music
      apply 0755 sonarr        sonarr  /tank/media/tv
      apply 0755 ${username}   users   /tank/media/games
    '';
  };
}
