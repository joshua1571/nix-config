{ pkgs, ... }: {
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
    power-profiles-daemon.enable = true;
  };
  environment.plasma6.excludePackages = [ pkgs.kdePackages.elisa ];
  programs.partition-manager.enable = true;
  #security.polkit.enable = true; # should be enabled by enabling kde
}
