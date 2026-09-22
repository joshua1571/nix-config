{
  config,
  lib,
  pkgs,
  ...
}:
{
  age.secrets.freshrss-password = {
    file = ../../secrets/freshrss-password.age;
    owner = "freshrss";
    mode = "0400";
  };

  services = {
    freshrss = {
      enable = true;

      extensions = with pkgs.freshrss-extensions; [
        youtube
      ];

      # baseUrl mostly affects absolute URLs in OPML export / emails.
      # Nav uses request-derived URLs, so a static placeholder is fine here.
      # If absolute-URL correctness matters later, inject the tailscale
      # hostname at runtime via an oneshot (see nextcloud.nix for the pattern).
      baseUrl = "https://server/freshrss";
      defaultUser = "josh";
      passwordFile = config.age.secrets.freshrss-password.path;

      authType = "http_auth";
      webserver = "nginx";
      database = {
        type = "pgsql";
        # /run/postgresql triggers unix-socket peer auth against the
        # freshrss pg role created below.
        host = "/run/postgresql";
      };
    };

    # Bind the freshrss-generated vhost to loopback so it isn't exposed on
    # the LAN. The nginx catch-all in nginx.nix reverse-proxies /freshrss/
    # to this port over the tailscale interface.
    nginx.virtualHosts.freshrss = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8083;
        }
      ];
      # Inject REMOTE_USER into the PHP location that the freshrss module
      # generates. Must live inside the PHP location block: nginx does not
      # inherit server-level fastcgi_param directives into a location that
      # already sets its own (via `include fastcgi_params`).
      locations."~ ^.+?\\.php(/.*)?$".extraConfig = lib.mkAfter ''
        fastcgi_param REMOTE_USER $http_remote_user;
      '';
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "freshrss" ];
      ensureUsers = [
        {
          name = "freshrss";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
