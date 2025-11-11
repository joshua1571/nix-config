# Not sure I like this very specific flag here
{ pkgs, config, lib, emulation, ... }: {
  home.packages = with pkgs;
    [
      # GUI Applications
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
      opensnitch # Requires opensnitch service
    ] ++ lib.optionals emulation [ ryubing ];
  programs = {
    mpv.enable = true;
    zathura.enable = true;
  };

}
