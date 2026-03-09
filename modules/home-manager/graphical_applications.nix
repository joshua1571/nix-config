{
  pkgs,
  lib,
  emulation,
  game-streaming-client,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # GUI Applications
      brave
      spotify
      discord
      obsidian
      ticktick
      ktailctl # Requires tailscale service
      brave
      bitwarden-desktop
      github-desktop
      libreoffice-qt6
      deskflow
      #opensnitch # Requires opensnitch service
      zapzap
      fastmail-desktop
      localsend
      thunderbird
      activitywatch
    ]
    ++ lib.optionals emulation [
      ryubing
    ]
    ++ lib.optionals game-streaming-client [
      moonlight-qt
    ];
}
