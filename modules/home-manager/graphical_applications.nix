<<<<<<< HEAD
# Not sure I like this very specific flag here
=======
>>>>>>> c3909fc67a700c48014a0c1731e581ec1fec402c
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
<<<<<<< HEAD
      brave
=======
      # GUI Applications
>>>>>>> c3909fc67a700c48014a0c1731e581ec1fec402c
      spotify
      discord
      obsidian
      ticktick
      ktailctl # Requires tailscale service
<<<<<<< HEAD
=======
      brave
>>>>>>> c3909fc67a700c48014a0c1731e581ec1fec402c
      bitwarden-desktop
      github-desktop
      libreoffice-qt6
      deskflow
<<<<<<< HEAD
      #opensnitch # Requires opensnitch service
=======
      opensnitch # Requires opensnitch service
>>>>>>> c3909fc67a700c48014a0c1731e581ec1fec402c
      zapzap
    ]
    ++ lib.optionals emulation [
      ryubing
    ]
    ++ lib.optionals game-streaming-client [
      moonlight-qt
    ];

  programs = {
    mpv.enable = true;
<<<<<<< HEAD
    zathura.enable = false;
=======
    zathura.enable = true;
>>>>>>> c3909fc67a700c48014a0c1731e581ec1fec402c
  };

}
