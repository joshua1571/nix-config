{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # GUI Applications
    brave
    spotify
    discord
    obsidian
    ticktick
    ktailctl # Requires tailscale service
    brave
    #bitwarden-desktop
    github-desktop
    libreoffice-qt6
    deskflow
    #opensnitch # Requires opensnitch service
    zapzap
    fastmail-desktop
    localsend
    thunderbird
    activitywatch
    openhue-cli
  ];
}
