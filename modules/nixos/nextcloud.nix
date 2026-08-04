{ config, pkgs, ... }:
{
  age.secrets.nextcloud-adminpass = {
    file = ../../secrets/nextcloud-adminpass.age;
    owner = "nextcloud";
    mode = "0400";
  };

  # The datadir lives on the tank/personal/nextcloud ZFS dataset. Native ZFS
  # mounts happen after systemd-tmpfiles runs (see hosts/server/storage.nix),
  # so ownership is applied via a oneshot ordered after zfs-mount instead.
  systemd.services.nextcloud-datadir-perms = {
    description = "Ensure Nextcloud datadir ownership on tank";
    wantedBy = [ "nextcloud-setup.service" ];
    before = [ "nextcloud-setup.service" ];
    after = [ "zfs-mount.service" ];
    unitConfig.RequiresMountsFor = [ "/tank/personal/nextcloud" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /tank/personal/nextcloud
      chown nextcloud:nextcloud /tank/personal/nextcloud
      chmod 0750 /tank/personal/nextcloud
    '';
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;

    # LAN-only for now. Reach it via http://server or http://<lan-ip>.
    # To move to Tailscale + nginx later: change hostName to the tailnet
    # hostname, flip https = true, and add overwriteProtocol = "https"
    # under settings below.
    hostName = "server";
    https = false;

    datadir = "/tank/personal/nextcloud";
    maxUploadSize = "16G";

    database.createLocally = true;
    configureRedis = true;

    config = {
      adminuser = "admin";
      adminpassFile = config.age.secrets.nextcloud-adminpass.path;
      dbtype = "pgsql";
    };

    settings = {
      default_phone_region = "US";

      # Every hostname a client might use in the Host header. Preload the
      # future Tailscale name so the migration is a routing change, not a
      # trusted-domains change.
      trusted_domains = [
        "server"
        "server.local"
        "localhost"
      ];
    };

    # Pin the core set declaratively; leave the web app store on for
    # anything else you want to try. Apps installed via the UI live in
    # the datadir and survive rebuilds; anything in extraApps is
    # re-pinned to nixpkgs on every rebuild.
    appstoreEnable = true;
    extraAppsEnable = true;
    extraApps = {
      inherit (pkgs.nextcloud31Packages.apps)
        contacts
        calendar
        tasks
        notes
        deck
        mail
        news
        ;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
