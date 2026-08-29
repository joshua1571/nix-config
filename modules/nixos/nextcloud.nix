{ config, pkgs, ... }:
{
  age.secrets.nextcloud-adminpass = {
    file = ../../secrets/nextcloud-adminpass.age;
    owner = "nextcloud";
    mode = "0400";
  };

  # The datadir lives on the tank/personal/nextcloud ZFS dataset. Native ZFS
  # mounts happen after systemd-tmpfiles-setup runs, so anything that rule
  # created under the datadir (subdirs + the override.config.php symlink)
  # gets shadowed once ZFS mounts on top. This oneshot re-applies both the
  # ownership fix and the tmpfiles rules after the mount is in place.
  systemd.services.nextcloud-datadir-perms = {
    description = "Prepare Nextcloud datadir on tank (post-ZFS-mount)";
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
      chown -R nextcloud:nextcloud /tank/personal/nextcloud
      chmod 0750 /tank/personal/nextcloud
      # Re-apply tmpfiles rules that landed on the pre-mount filesystem —
      # in particular the override.config.php symlink that declares
      # apps_paths (without it, nix-apps/store-apps aren't registered and
      # `app:enable` fails with "Cannot write into apps directory").
      ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix=/tank/personal/nextcloud
    '';
  };

  # Register the tailscale hostname as a trusted domain at runtime, since
  # it's stored in an agenix secret and can't be baked into settings.
  systemd.services.nextcloud-trusted-domains-tailscale = {
    description = "Register tailscale hostname as a Nextcloud trusted domain";
    wantedBy = [ "multi-user.target" ];
    after = [ "nextcloud-setup.service" ];
    requires = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nextcloud";
      Group = "nextcloud";
      # Expose the root-owned agenix secret to the nextcloud user via a
      # per-service credentials dir (only readable by this unit).
      LoadCredential = "tailscale-hostname:${config.age.secrets.tailscale-hostname.path}";
    };
    script = ''
      hostname=$(cat "$CREDENTIALS_DIRECTORY/tailscale-hostname")
      occ=${config.services.nextcloud.occ}/bin/nextcloud-occ
      $occ config:system:set trusted_domains 4 --value="$hostname"
      # URL-generation overrides for the tailnet reverse-proxy path.
      # These pair with overwritecondaddr (set in settings) so they only
      # apply to requests coming in via 127.0.0.1 (i.e. the nginx proxy),
      # leaving direct LAN hits at http://server untouched.
      $occ config:system:set overwritehost --value="$hostname"
      $occ config:system:set overwrite.cli.url --value="https://$hostname/nextcloud"
    '';
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;

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
      # The tailscale hostname is injected at runtime by
      # nextcloud-trusted-domains-tailscale.service — it lives in an agenix
      # secret and can't be evaluated at build time.
      trusted_domains = [
        "server"
        "server.local"
        "localhost"
        "10.0.0.126"
      ];

      # Reverse-proxy overrides for the tailnet path. The paired
      # overwritehost and overwrite.cli.url values are injected at
      # runtime by nextcloud-trusted-domains-tailscale.service because
      # the tailnet hostname is an agenix secret.
      # overwritecondaddr scopes all overwrite* settings to requests
      # arriving from 127.0.0.1 (the nginx reverse proxy on this host),
      # so LAN clients hitting http://server directly still get plain
      # http URLs back.
      overwriteprotocol = "https";
      overwritewebroot = "/nextcloud";
      overwritecondaddr = "^127\\.0\\.0\\.1$";
      trusted_proxies = [ "127.0.0.1" ];

      # Nextcloud's DnsPinMiddleware refuses server-side HTTP calls to
      # addresses it classifies as "local" (RFC1918 + 100.64/10 CGNAT).
      # Tailnet IPs live in the CGNAT range, so the user_oidc app can't
      # fetch Authelia's discovery URL over the tailnet FQDN without this.
      allow_local_remote_servers = true;
    };

    # Pin the core set declaratively; leave the web app store on for
    # anything else you want to try. Apps installed via the UI live in
    # the datadir and survive rebuilds; anything in extraApps is
    # re-pinned to nixpkgs on every rebuild.
    appstoreEnable = true;
    extraAppsEnable = true;
    extraApps = {
      inherit (pkgs.nextcloud32Packages.apps)
        contacts
        calendar
        tasks
        notes
        deck
        mail
        qownnotesapi
        user_oidc
        ;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
