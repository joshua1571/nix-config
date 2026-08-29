# TODOs

Single source of truth for outstanding work in this repo. When something is
done, delete the entry — don't leave breadcrumbs in the code.

## Flake / infra

- Set up [colmena](https://github.com/zhaofengli/colmena) for remote deploys.
- Migrate server disks to declarative [disko](https://github.com/nix-community/disko) config.
- Add raspberry pi to the flake (via [nixos-hardware](https://github.com/NixOS/nixos-hardware)).
- Modularize the flake with [flake-parts](https://github.com/hercules-ci/flake-parts).
- Try a Wayland tiling WM; if it doesn't stick, evaluate [plasma-manager](https://github.com/nix-community/plasma-manager) as a replacement for the ambient nixpkgs plasma module.

## Hosts

### laptop

- Fill in hardware in `README.md`: CPU, GPU, RAM, wired NIC.
- Decide whether Mullvad / Nextcloud client should run here.
- Document host-specific home-manager state (wallpapers, KDE layout).

### desktop

- `openrgb.nix` does not see RAM RGB lights — investigate.
- Document games disk device path / filesystem in `README.md`.
- Finish implementing Sunshine/Moonlight
- Look into [Romm](https://github.com/rommapp/romm)

### server

- Fill in hardware in `README.md`: CPU, RAM, NIC model + link speed.
- Decide whether `home-assistant` and `syncthing` (modules exist, unimported) should run here.
- Document actual Tailscale hostname/domain values outside agenix for human reference.
- Add backup strategy: who pulls from `tank/backups/*`, retention policy.
- Add ntfy access token auth: currently anyone on the tailnet who guesses a topic name can publish/subscribe. Encrypt a token via agenix, set `services.ntfy-sh.settings.auth-file` + `auth-default-access = "deny-all"`, and update the netdata/gatus/notify-failure/zfs-health-check publishers to send it in an Authorization header.
- Look into [healthchecks.io](https://healthchecks.io/)
- Look into [scrutiny]P(https://github.com/AnalogJ/scrutiny)
- Bookmarking [linkwarden](https://github.com/linkwarden/linkwarden) or [karakeep](https://github.com/karakeep-app/karakeep)
- Evaluate nextcloud need and see if I can replace with [filebrowser](https://github.com/gtsteffaniak/filebrowser?tab=readme-ov-file)
- Look into [vikunja](https://vikunja.io/)

#### Authelia — SSO hardening (Phase 5)

Enroll TOTP and move admin surfaces from `one_factor` to `two_factor`. Current
`access_control` in `authelia.nix` is `default_policy = "one_factor"; rules = [];`
— anyone who authenticates once reaches everything.

1. Log into `https://<server>.<tailnet>/authelia/` and enroll TOTP under your
   user's settings (Register device → TOTP). Confirm the code round-trips.
2. Update `modules/nixos/authelia.nix` `access_control` to:
   ```nix
   default_policy = "deny";
   rules = [
     # Admin surfaces — TOTP required, admins-only.
     { domain = "<fqdn>"; resources = [
         "^/radarr.*" "^/sonarr.*" "^/lidarr.*" "^/prowlarr.*"
         "^/qbittorrent.*" "^/prometheus.*" "^/alertmanager.*"
         "^/grafana.*" "^/lldap.*"
       ]; policy = "two_factor"; subject = ["group:admins"]; }
     # Media + dashboard — 1FA is fine.
     { domain = "<fqdn>"; resources = [
         "^/jellyfin.*" "^/navidrome.*" "^/immich.*" "^/nextcloud.*" "^/freshrss.*" "^/$"
       ]; policy = "one_factor"; }
     # *arr + Jellyfin API-key paths bypass Authelia (callers auth via API key).
     { domain = "<fqdn>"; resources = [
         "^/radarr/api/.*" "^/sonarr/api/.*" "^/lidarr/api/.*"
         "^/prowlarr/api/.*" "^/jellyfin/.*/api.*"
       ]; policy = "bypass"; }
   ];
   ```
   Domain has to come from a runtime settingsFile the same way `session.cookies`
   does now (tailscale hostname is a secret) — extend the `authelia-runtime-config`
   oneshot to also write the `access_control.rules[*].domain` values.
3. Bump `session.expiration` from `1h` → something more forgiving (`8h`+) so
   TOTP prompts aren't relentless. Consider `remember_me = "1M"` (already set).
4. **Break-glass**: keep at least one path unaffected in case your TOTP device
   dies — the local admin accounts on Nextcloud/Jellyfin/Grafana already serve
   this purpose, so admin-tier lockout doesn't lock you out of everything.
5. Optional: create a dedicated `authelia_bind` LLDAP user with only
   `lldap_strict_readonly` group (already done in Phase 2 follow-up) — verify
   it isn't in `admins`.

Verification: fresh incognito → `/radarr/` → Authelia 1FA → TOTP prompt →
Radarr. Any admin who isn't in `admins` should get 403 at Authelia.

#### App-local user cleanup + LLDAP admin exposure (Phase 7)

After Phase 5 is stable, tighten per-app user surfaces so OIDC/forward-auth is
the only real way in.

- **Nextcloud**: keep the local `admin` (break-glass); delete or disable any
  other local users. Under Settings → Administration → Security, consider
  disallowing user self-registration and forcing OIDC for non-admins.
- **Immich**: Settings → Authentication → toggle **Password Login off**
  (leaves OIDC as the only path). Keep the local admin as break-glass.
- **Jellyfin**: for regular family users, Users → *user* → uncheck "Allow this
  user to sign in" via the standard Jellyfin auth — leaves SSO as the path.
  Keep local admin.
- **Grafana**: `services.grafana.settings."auth".disable_login_form = true;`
  leaves OAuth as the only front-door (but the admin CLI still works — no
  full lockout). Keep local admin as break-glass in `admin_user`.
- **FreshRSS**: already HTTP-auth only; nothing to change.
- **qBittorrent**: `LocalHostAuth = false` for loopback already means nginx
  forward-auth is the only real gate. Nothing more to do.
- **LLDAP admin UI**: currently loopback-only (port-forward with
  `ssh -L 17170:localhost:17170 server`). Optionally expose behind Authelia
  at `/lldap/` — add an nginx location with `autheliaSnippet`, gated to
  `group:admins` via `access_control`. LLDAP itself doesn't support subpath
  serving upstream, so it'd need a dedicated HTTPS listener like Immich has
  on `:2443` (e.g. `:17443`) — or wait for upstream subpath support. Once
  reachable, add an **LLDAP** tile to `homepage-dashboard.nix`
  Administration bookmarks (icon: `sh-lldap` or `mdi-account-group`;
  href: `https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}:17443/`).
- **Jellyseerr OIDC**: deferred in Phase 6c because Jellyseerr doesn't
  support subpath serving. Options if we come back to it:
  1. Second nginx TLS listener on a different port (e.g. `:5443`) using the
     existing tailscale cert, then set up native OIDC in Jellyseerr's UI.
  2. Register a second tailscale node purely for Jellyseerr so it can have
     its own MagicDNS name + cert.
  3. Wait for upstream subpath support ([overseerr#171](https://github.com/sct/overseerr/issues/171)).

Also relevant to revisit here: `authelia.nix` currently comments that the
LDAP bind user (`authelia_bind`) should live in `lldap_strict_readonly` only.
Confirm this is still true and remove the follow-up comment.

### htpc

- Re-add `htpc` as a `nixosConfiguration` in `flake.nix` (was removed; likely to be an unstable-channel host on Mac mini hardware).
- Fill in hardware in `README.md`: CPU (matters for QSV codec matrix), RAM, network (wired preferred for streaming).
- Consider adding `pkgs.moonlight-qt` so the living room can receive streams from `desktop`.
- Consider auto-launching Jellyfin Media Player or a kiosk session on boot.
- Revisit `initrd.systemd.tpm2.enable = false` once the boot-time TPM2 issue is understood.

## Nixvim

- **Keymap cheatsheet.** Generate (or hand-write) a table in `docs/nixvim_documentation.md` covering every custom keymap from `nixvim_keymaps.nix` (mode, lhs, rhs, description) so the doc, not the nix source, is the lookup surface.
- Fix hints for the `hardtime` plugin and re-add `./nixvim_plugins/hardtime.nix` to the imports in `modules/home-manager/nixvim.nix`.
- Add a debugger via [nvim-dap](https://github.com/mfussenegger/nvim-dap). Inspiration: [Ahwxorg/nixvim-config](https://github.com/Ahwxorg/nixvim-config/blob/master/config/plugins.nix).
