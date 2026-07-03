{ pkgs, ... }:
{
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = true;
  };
  environment.plasma6.excludePackages = [ pkgs.kdePackages.elisa ];
  programs.partition-manager.enable = true;
	programs.kde-pim.enable = true;
	programs.kde-pim.kmail = true;
	programs.kde-pim.kontact = true;
	programs.kde-pim.merkuro = true;
  #security.polkit.enable = true; # should be enabled by enabling kde
}
