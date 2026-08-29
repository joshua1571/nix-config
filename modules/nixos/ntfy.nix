_: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      # Listen on all interfaces so the phone (over tailscale) and local
      # publishers (netdata, gatus on loopback) can both reach it.
      listen-http = ":8085";
      # Fallback for click URLs / attachments; most endpoints are
      # request-derived so the exact value rarely matters day-to-day.
      base-url = "http://server:8085";
      behind-proxy = false;
      cache-file = "/var/lib/ntfy-sh/cache.db";
      cache-duration = "12h";
      attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
      # Open topics: anyone on tailscale who guesses the topic name can
      # publish/subscribe. Fine for a personal server; add auth-file later
      # if the tailnet grows.
      auth-default-access = "read-write";
    };
  };

  # Expose on tailscale (and LAN) so the phone app can subscribe.
  networking.firewall.allowedTCPPorts = [ 8085 ];
}
