{ config, pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = [
      pkgs.obs-studio-plugins.wlrobs
      pkgs.obs-studio-plugins.obs-vaapi
      pkgs.obs-studio-plugins.droidcam-obs
      pkgs.obs-studio-plugins.obs-vkcapture
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
    ];
  };

  services.usbmuxd.enable = true; # iPhone filesystem access

  environment.systemPackages = with pkgs; [
    v4l-utils
    droidcam
  ];

  boot = {
    # Make v4l2loopback kernel module available to NixOS.
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    # Activate kernel module(s).
    kernelModules = [
      # Virtual camera.
      "v4l2loopback"
      # Virtual Microphone. Custom DroidCam v4l2loopback driver needed for audio.
      "snd-aloop"
    ];
  };

}
