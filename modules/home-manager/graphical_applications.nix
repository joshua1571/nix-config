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
    github-desktop
    libreoffice-qt6
    deskflow
    localsend
    remmina
    ktailctl
    activitywatch
    openhue-cli
    #opensnitch # Requires opensnitch service
    #bitwarden-desktop
    # Use web app instead
    #ticktick
    #zapzap
    #fastmail-desktop
    #thunderbird
  ];
}
