{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /tank/media/torrents									0755 jrh users -"
    "d /tank/media/torrents/books						0755 jrh users -"
    "d /tank/media/torrents/movies     			0755 radarr radarr -"
    "d /tank/media/torrents/music      			0755 lidarr lidarr-"
    "d /tank/media/torrents/tv         			0755 sonarr sonarr -"
    "d /tank/media/torrents/games      			0755 jrh users -"

    "d /tank/media/usenet              			0755 jrh users -"
    "d /tank/media/usenet/incomplete   			0755 jrh users -"
    "d /tank/media/usenet/complete/books    0755 jrh users -"
    "d /tank/media/usenet/complete/movies   0755 jrh users -"
    "d /tank/media/usenet/complete/music    0755 jrh users -"
    "d /tank/media/usenet/complete/tv       0755 jrh users -"
    "d /tank/media/usenet/complete/games    0755 jrh users -"

    "d /tank/media/books										0755 jrh users -"
    "d /tank/media/movies              			0755 jrh users -"
    "d /tank/media/music               			0755 lidarr lidarr -"
    "d /tank/media/tv                  			0755 jrh users -"
    "d /tank/media/games               			0755 jrh users -"

    "d /tank/personal/photos           			0755 jrh users -"
    "d /tank/personal/photos/immich_data    0755 jrh users -"
    "d /tank/personal/documents             0755 jrh users -"
    "d /tank/personal/downloads							0755 jrh users -"
    "d /tank/personal/development						0755 jrh users -"
  ];
}
