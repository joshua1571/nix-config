{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.opensnitch-ui ];
  services.opensnitch.enable = true;
}
