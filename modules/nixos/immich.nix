_: {
  services.immich = {
    enable = true;
    # Loopback only; reached via nginx TLS on :2443 (see nginx.nix
    # "_immich" vhost). Immich doesn't support subpath serving, so it gets
    # a dedicated HTTPS port instead of sitting under the main catch-all.
    host = "127.0.0.1";
    port = 2283;
    openFirewall = false;
    accelerationDevices = null;
    mediaLocation = "/tank/personal/photos/immich";
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
    "users"
    "media"
  ];
}
