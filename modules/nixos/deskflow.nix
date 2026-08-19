{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.local.deskflow.isServer = lib.mkEnableOption "deskflow server mode";

  config = {
    environment.systemPackages = [ pkgs.deskflow ];

    networking.firewall.allowedTCPPorts = lib.mkIf config.local.deskflow.isServer [ 24800 ];
  };
}
