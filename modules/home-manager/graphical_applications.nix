{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    brave
    spotify
    discord
    ticktick
    obsidian
    libreoffice-qt6
    deskflow
    localsend
    ktailctl
    easyeffects
    #activitywatch # broken in nixpkgs-unstable: aw-core requires peewee==3.* but unstable has 4.x
    jellyfin-desktop
    strawberry
    nextcloud-client
    calibre
    teams-for-linux
    zoom-us
    qownnotes
  ];
}
