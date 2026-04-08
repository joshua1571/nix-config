{ config, ... }:
{
  age.secrets.nextcloud-adminpass = {
    file = ../../secrets/nextcloud-adminpass.age;
    owner = "nextcloud";
    mode = "0400";
  };

  services.nextcloud = {
    enable = true;
    # Set to your tailscale hostname or local DNS name
    hostName = "nextcloud.example.ts.net";
    https = false;
    database.createLocally = true;
    config = {
      adminpassFile = config.age.secrets.nextcloud-adminpass.path;
      adminuser = "admin";
      dbtype = "pgsql";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
