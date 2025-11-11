{ pkgs, ... }: {
  home.packages = with pkgs; [
    kdePackages.yakuake
    #kdePackages.kamoso #Error: Marked broken in nixpkgs
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.koko
    kdePackages.ksshaskpass
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.plasma-disks
    kdePackages.plasma-browser-integration
    kdePackages.xdg-desktop-portal-kde
    kdePackages.sddm-kcm
    kdePackages.wayland
    kdePackages.wayland-protocols
  ];
}
