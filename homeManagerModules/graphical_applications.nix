{ pkgs, ... }: {
  home.packages = with pkgs; [
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
  ];
  programs = {
    mpv.enable = true;
    zathura.enable = true;
  };
}
