# FreshRSS Auth Recovery

If FreshRSS's authentication mode is set to HTTP (for SSO via Authelia) and
you lock yourself out — the LLDAP username doesn't match a FreshRSS user, a
typo in the setting, the reverse proxy stops forwarding `Remote-User`, etc.
— you can fall back to form auth by editing the config file directly.

```bash
sudo sed -i "s/'auth_type' => '[^']*'/'auth_type' => 'form'/" \
  /var/lib/freshrss/data/config.php

# No service restart needed — FreshRSS re-reads config.php on next request.
```

Then reach `https://<server>.<tailnet>/freshrss/`, log in with your FreshRSS
password (the one in `secrets/freshrss-password.age`), and fix whatever's
wrong in **⚙ → Administration → Authentication** before switching HTTP auth
back on.

## Prereqs for HTTP auth to work

- Nginx catch-all wraps `/freshrss/` in `autheliaSnippet` (see `nginx.nix`)
  so Authelia sets a `Remote-User` header on the proxied request.
- FreshRSS's loopback nginx vhost forwards it to PHP-FPM as `REMOTE_USER`
  via `fastcgi_param REMOTE_USER $http_remote_user;` (see `freshrss.nix`).
- The LLDAP username matches an existing FreshRSS username exactly
  (case-sensitive). The default user set via `services.freshrss.defaultUser`
  is what FreshRSS created on first boot.
