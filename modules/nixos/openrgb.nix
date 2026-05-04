# https://github.com/Misterio77/nix-config/blob/main/modules/nixos/openrgb.nix
# Adds a settings option, for declarative config
{
  pkgs,
  lib,
  config,
  ...
}:

# Doesn't seem to be working on desktop host
let
  cfg = config.services.hardware.openrgb;
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "OpenRGB" cfg.settings;
in
{
  disabledModules = [ "services/hardware/openrgb.nix" ];

  options.services.hardware.openrgb = {
    enable = lib.mkEnableOption "OpenRGB server, for RGB lighting control";

    package = lib.mkPackageOption pkgs "openrgb" { };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };
    };

    motherboard = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
        ]
      );
      default = "intel";
      defaultText = "intel";
      description = ''
        CPU family of motherboard. This enables I2C support needed for motherboard RGB controllers and RAM lighting.
        
        Common values:
        - "intel" for Intel chipsets (Z790, B760, H770, etc.)
        - "amd" for AMD chipsets (B650, X670, etc.)
        
        If unsure, set this to the appropriate value for your motherboard.
      '';
    };

    server.port = lib.mkOption {
      type = lib.types.port;
      default = 6742;
      description = "Set server port of openrgb.";
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];

    boot.kernelModules = [
      "i2c-dev"
    ]
    ++ lib.optionals (cfg.motherboard == "amd") [ "i2c-piix4" ]
    ++ lib.optionals (cfg.motherboard == "intel") [ "i2c-i801" ];

    systemd.services.openrgb = {
      description = "OpenRGB server daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        StateDirectory = "OpenRGB";
        WorkingDirectory = "/var/lib/OpenRGB";
        ExecStartPre = lib.optionalString (
          cfg.settings != { }
        ) "${lib.getExe' pkgs.coreutils "cp"} --dereference ${settingsFile} /var/lib/OpenRGB/OpenRGB.json";
        ExecStart = "${lib.getExe cfg.package} --verbose --server --server-port ${toString cfg.server.port} --config /var/lib/OpenRGB";
        Restart = "always";
      };
    };
  };

  meta.maintainers = [ ];
}
