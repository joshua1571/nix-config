{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kdePackages.yakuake
    #kdePackages.kamoso #Error: Marked broken in nixpkgs
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.koko
    kdePackages.kdeconnect-kde
    kdePackages.ksshaskpass
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.plasma-disks
    kdePackages.plasma-browser-integration
    kdePackages.xdg-desktop-portal-kde
    kdePackages.sddm-kcm
    kdePackages.wayland
    kdePackages.wayland-protocols
    haruna
    #kdePackages.kontact
    #kdePackages.kmail
    #kdePackages.korganizer
    #kdePackages.kaddressbook
    #kdePackages.akonadi
    #kdePackages.akonadi-contacts
    #kdePackages.akonadi-calendar
    #kdePackages.akonadi-mime
    #kdePackages.akonadi-search
    #kdePackages.kdepim-runtime
    #kdePackages.kdepim-addons
    #kdePackages.kmailtransport
    #kdePackages.kmail-account-wizard
    #kdePackages.kldap
    #kdePackages.merkuro
  ];
}
