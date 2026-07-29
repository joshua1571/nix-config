_: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };
  hardware.steam-hardware.enable = true;

  services.udev.extraRules = ''
        # Steam Controller
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", MODE="0666"

    	  # Steam Controller Bluetooth
        SUBSYSTEM=="input", ATTRS{name}=="Steam Controller", MODE="0666"
  '';
}
