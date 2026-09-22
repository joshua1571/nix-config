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

  # Cap Redis memory so a large job backlog can't OOM the whole system.
  # noeviction: when the limit is hit, Redis rejects new writes rather than
  # silently dropping BullMQ job records (which would corrupt the queue).
  services.redis.servers.immich.settings = {
    maxmemory = "2gb";
    maxmemory-policy = "noeviction";
  };

  systemd.services = {
    immich-server = {
      # Hard memory ceilings on the two Immich systemd units. MemoryHigh
      # triggers throttling; MemoryMax kills the service before the kernel OOM
      # killer takes down an unrelated process.
      serviceConfig = {
        MemoryHigh = "3G";
        MemoryMax = "4G";
      };
      # Without an explicit V8 heap limit, V8 grows until it hits MemoryHigh,
      # at which point the cgroup throttles and pushes pages to swap. GC then
      # traverses swap-backed pages, becomes "ineffective", and V8 aborts the
      # process via FatalProcessOutOfMemory. Telling V8 its budget upfront causes
      # it to GC aggressively before reaching the cgroup wall.
      environment = {
        NODE_OPTIONS = "--max-old-space-size=2048";
      };
    };
    immich-machine-learning.serviceConfig = {
      MemoryHigh = "2G";
      MemoryMax = "2500M";
    };
  };

}
