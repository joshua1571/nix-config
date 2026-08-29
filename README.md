# nix-config

NixOS + home-manager flake for four hosts: `laptop`, `desktop`, `server`, `htpc`.

## Commands

Run from repo root via `just`:

| Command | Description |
|---|---|
| `just build` | `nixos-rebuild switch --flake '.#'` on current host |
| `just dry` | Dry-build / dry-activate to verify the flake compiles |
| `just fmt` | Format all `.nix` files with `nixfmt` |
| `just lint` | Lint all `.nix` files with `statix` |
| `just up` | `nix flake update` |
| `just gc` | GC nix store entries older than 7 days |
| `just clean` | Wipe system profile generations older than 7 days |
| `just repl` | Open a nix repl scoped to the flake |

Build a specific host: `sudo nixos-rebuild switch --flake '.#<hostname>'`.

## Architecture

### Flake

`flake.nix` defines the active `nixosConfigurations`. `laptop`, `desktop`, and
`server` are all on stable nixpkgs (`nixos-25.11`); `htpc` is commented out
pending re-add as an unstable host. Each host receives `specialArgs`
(`username`, `system`, `inputs`, feature flags) threaded through every module.

Feature flags:
- `desktop-environment` — KDE, browser, graphical apps
- `game-streaming-client` / `game-streaming-server`
- `emulation`

### Module layers

- **NixOS modules** (`modules/nixos/`) — system-level. Every host imports
  `common.nix` (user account, nix settings, firewall off, base packages,
  tailscale, fonts).
- **Home-manager modules** (`modules/home-manager/`) — user-level. All hosts
  get the base set (bash, git, nixvim, tmux, cli tools); desktop hosts add
  browser, KDE, graphical apps, and terminal via `lib.optionals
  desktop-environment`.
- **Host configs** (`hosts/<name>/default.nix`) — compose modules for that
  machine. Minimal host-specific settings + an `imports` list.

### Secrets (agenix)

Encrypted secrets live in `secrets/*.age`. The decryption key registry is
`secrets.nix` at the **repo root** (agenix requires this — run
`agenix -e secrets/<file>.age` from repo root). `modules/nixos/agenix.nix`
installs the CLI on each host; modules that consume a secret declare it via
`age.secrets.<name>.file = ...`.

### Nixvim

See [`docs/nixvim_documentation.md`](./docs/nixvim_documentation.md).

## Docs

- [`docs/TODO.md`](./docs/TODO.md) — single source of truth for outstanding work across the flake, hosts, and modules.
- [`docs/nixvim_documentation.md`](./docs/nixvim_documentation.md) — nixvim layout and keymap conventions.
- [`docs/freshrss_recovery.md`](./docs/freshrss_recovery.md) — how to unstick FreshRSS if the SSO HTTP-auth path locks you out.
- [`docs/troubleshooting/`](./docs/troubleshooting) — dated incident writeups.

## Hosts

Each host section below is the source of truth for *what* the host should do.
The nix modules under `hosts/<name>/` and `modules/` are the implementation.
To close drift, ask an agent something like:

> Reconcile hosts/server with the server section of README.md. List drift first
> (spec items not implemented, modules not in spec), then propose changes.

---

### `laptop` — portable workstation, game-streaming client

**Hardware**
- Storage: LUKS-encrypted root (see `hardware-configuration.nix`)
- Wifi: MediaTek mt7921e (ASPM disabled via `extraModprobeConfig` for stability)
- Bluetooth: on, powers up at boot
- Input: touchpad (libinput)
- Kernel: `linuxPackages_latest`

**Composition**
- NixOS: see `hosts/laptop/default.nix`
- Home-manager (`users/jrh/home/laptop.nix`): `common.nix` + `desktop-environment.nix` + `pkgs.moonlight-qt`

**Functionality**
- KDE Plasma, `jrh` user (from `common.nix`)
- SSH server, GnuPG agent, OBS Studio
- SMB **client** (mounts `server` shares)
- Game-streaming client (receives from `desktop`)
- Tailscale (from `common.nix`)

**Networking** — Tailscale client; LAN port 22 (SSH); no extra tailscale-only ports.

**Secrets** — none directly; inherits `common.nix` / `agenix.nix`.

---

### `desktop` — workstation, game-streaming server, emulation

**Hardware**
- CPU: AMD Ryzen 9 5900X
- GPU: AMD Radeon RX 6800 XT
- RAM: 64 GB
- Storage: root (see `hardware-configuration.nix`); games disk via
  `modules/nixos/games_disk.nix`; unmanaged Windows disk on `/dev/sda` (256 GB)
- Wifi: MediaTek mt7921e (ASPM disabled)
- Wired: Realtek RTL8125 2.5GbE (rev 05)
- Bluetooth: on, powers up at boot
- Kernel: `linuxPackages_latest`
- Peripherals: Ducky One 2 Mini kbd, Glorious Model D Wireless mouse,
  Taotronics TT-BA014 audio, Sennheiser Profile mic, Gamesir Cyclone 2 controller

**Composition**
- NixOS: see `hosts/desktop/default.nix`
- Home-manager (`users/jrh/home/desktop.nix`): `common.nix` + `desktop-environment.nix` + `pkgs.ryubing`

**Functionality**
- KDE Plasma
- Steam + game-streaming server (Sunshine/Moonlight)
- Emulation suite (ryubing / Nintendo Switch via home-manager)
- Local AI inference server (`local_ai_server.nix`)
- Dedicated games disk mount, OBS Studio
- SMB **client** (mounts `server` shares)
- SSH server, GnuPG agent, Tailscale

**Networking** — Tailscale client.

**Secrets** — none directly.

---

### `server` — headless media / automation / storage

Runs the self-hosted media stack, *arr automation, photo backup, file sharing,
and a Tailscale-fronted reverse proxy. Bulk and fast storage for the household.
Uses **stable** nixpkgs (`nixos-25.11`).

**Hardware**
- GPU: integrated, used for Jellyfin transcoding (`hardware.graphics.enable = true`)
- Storage: `tank` (bulk HDD ZFS), `fasttank` (SSD/NVMe ZFS); root per `hardware-configuration.nix`

**Composition**
- NixOS: see `hosts/server/default.nix` (zfs, smb_share_server, mullvad, nginx, media + arr stack, …)
- Home-manager (`users/jrh/home/server.nix`): `common.nix` only (headless)

**Functionality**

| Category | Service | Port / notes |
|---|---|---|
| Media | Jellyfin | `:8096`, LAN. Base URL `/jellyfin`, OIDC via `sso-auth` plugin (installed via Jellyfin plugin catalog). |
| Media | Navidrome | default, LAN. Reverse-proxied at `/navidrome/`. |
| Media | Immich | `:2283` bound loopback; reached via dedicated nginx HTTPS listener on `:2443` (Immich doesn't support subpath serving). Native OIDC configured in Immich admin UI. |
| Files | Nextcloud | `:80`, LAN. PostgreSQL + Redis, datadir `tank/personal/nextcloud`. Admin pw in `nextcloud-adminpass.age`. `user_oidc` app configured against Authelia; `allow_local_remote_servers=true` so PHP can reach the tailnet FQDN. |
| RSS | FreshRSS | Own nginx vhost on `127.0.0.1:8083`, reverse-proxied at `/freshrss/`. PostgreSQL via unix socket. SSO via HTTP-auth mode: nginx forwards Authelia's `Remote-User` to PHP-FPM as `REMOTE_USER`. See [docs/freshrss_recovery.md](./docs/freshrss_recovery.md) if locked out. |
| *arr | Radarr / Sonarr / Lidarr / Prowlarr / Jellyseerr / Flaresolverr | defaults, LAN. All *arr apps gated by Authelia forward-auth at nginx; each app's own auth set to "Disabled for Local Addresses". Jellyseerr keeps its own auth (no upstream subpath support — see `docs/TODO.md`). |
| Downloads | qBittorrent | `openFirewall = false`. Traffic kill-switched to `tailscale0` via nftables. Web UI `:8080`, **Tailscale-only**, behind Authelia forward-auth. |
| Reverse proxy | nginx | HTTPS via Tailscale cert (`server_name _` catch-all on `:443`, plus a dedicated `:2443` listener for Immich). `recommendedProxySettings = false`; per-location `proxyHeaders` / `autheliaSnippet` helpers in `nginx.nix` control `X-Forwarded-*` shaping (auth'd locations pin XFF to loopback so upstream "local address" auth-bypass works). |
| SSO / identity | Authelia | Loopback, reached at `/authelia/`. SQLite storage, LDAP backend to LLDAP, OIDC issuer with per-client PHC-hashed secrets. Runtime cookie-domain config assembled from `tailscale-hostname.age`. |
| SSO / identity | LLDAP | Loopback (`:3890` LDAP, `:17170` admin UI); admin reached via SSH port-forward for now. Base DN `dc=homelab,dc=local`. Two service accounts in `lldap_strict_readonly`: the admin bootstrap, and `authelia_bind` used by Authelia. |
| Monitoring | Prometheus | Loopback `:9090`, `--web.route-prefix=/prometheus`. Node + ZFS + systemd + nginx + Postgres exporters, all loopback. Reverse-proxied at `/prometheus/` behind Authelia. |
| Monitoring | Alertmanager | Loopback `:9093`, `--web.route-prefix=/alertmanager`. Routes to a local `alertmanager-ntfy` bridge, which publishes to ntfy `server-alerts`. Reverse-proxied at `/alertmanager/` behind Authelia. |
| Monitoring | Grafana | Loopback `:3000`, `serve_from_sub_path` under `/grafana`. Prometheus datasource + Node Exporter Full dashboard provisioned. OIDC via Authelia (env-injected endpoints); role-mapped via LLDAP `admins` group. Admin pw in `grafana-admin-password.age`. |
| Monitoring | Gatus | `:8084`. HTTP healthchecks against every service on loopback (bypasses nginx); alerts to ntfy `server-uptime`. |
| Monitoring | ntfy | `:8085`. Push notifications for alertmanager + gatus + notify-failure + zfs-health-check. |
| Dashboard | Homepage Dashboard | `:8082`, behind Authelia forward-auth at `/`. Tailnet domain from `tailscale-domain.age`. All widget backend calls hit `127.0.0.1` server-side so they bypass nginx and stay live behind SSO. |
| Other | ZFS, SMB server, Mullvad WireGuard (qBittorrent VPN), SSH, GnuPG | |

**Networking**
- Tailscale node, hostname registered in agenix
- LAN TCP: 22 (SSH), 80 (Nextcloud), 8096 (Jellyfin), Navidrome, arr defaults,
  8082 (Homepage), 8084 (Gatus), 8085 (ntfy), 5055 (Jellyseerr), SMB
- Tailscale-only TCP:
  - 443 (nginx catch-all — Homepage, Jellyfin, Navidrome, *arr, qBittorrent,
    Nextcloud, FreshRSS, Prometheus, Alertmanager, Grafana, Authelia portal)
  - 2443 (nginx TLS listener dedicated to Immich — no subpath support upstream)
- Loopback only: LLDAP (`:3890` LDAP, `:17170` admin UI), Prometheus, Alertmanager,
  Grafana, Immich backend, Authelia, exporters
- Mullvad WireGuard interface for qBittorrent

**Storage layout** — defined in `hosts/server/storage.nix` via
`boot.zfs.extraPools` and `systemd.tmpfiles.rules`. Native ZFS mountpoints —
do **not** add these datasets to `hardware-configuration.nix`.

`tank` (bulk):
- `tank/backups/{desktop,laptop,macbookpro}` — host backups
- `tank/media/{movies,tv,music,books,games}` — finished media
- `tank/media/torrents/*` — qBittorrent download dirs (per-arr ownership)
- `tank/media/usenet/*` — usenet incomplete + complete
- `tank/personal/{photos,documents,downloads,development}` — personal files
- `tank/personal/photos/immich` — immich backing store

`fasttank` (fast):
- `fasttank/containers` — docker data root

**Secrets (agenix)**

| Secret | Used by | Purpose |
|---|---|---|
| `tailscale-hostname.age` | `nginx.nix` / `authelia.nix` / `grafana.nix` / `nextcloud.nix` | Tailscale cert hostname; also referenced by Authelia's cookie-domain and OIDC redirect_uri templates (declared with an authelia-scoped name so its decrypted copy is readable by `authelia-main`) |
| `tailscale-domain.age` | `homepage-dashboard.nix` | Dashboard domain |
| `mullvad-wg-private-key.age` | `mullvad.nix` | WireGuard private key |
| `mullvad-wg-preshared-key.age` | `mullvad.nix` (commented) | WG preshared key |
| `nextcloud-adminpass.age` | `nextcloud.nix` | Nextcloud admin password |
| `freshrss-password.age` | `freshrss.nix` | FreshRSS default user password (break-glass; SSO uses HTTP auth) |
| `homepage-*.age` | `homepage-dashboard.nix` | Per-service widget API keys / creds |
| `grafana-admin-password.age` | `grafana.nix` | Grafana local admin password |
| `lldap-jwt-secret.age` / `lldap-key-seed.age` / `lldap-admin-password.age` | `lldap.nix` | JWT signing, DB encryption seed, admin bootstrap password |
| `authelia-jwt-secret.age` / `authelia-storage-encryption-key.age` | `authelia.nix` | Authelia identity-validation JWT + storage encryption |
| `authelia-oidc-hmac-secret.age` / `authelia-oidc-jwks-key.age` | `authelia.nix` | OIDC HMAC + RSA JWKS private key (do NOT rotate JWKS while tokens are in the wild) |
| `authelia-lldap-bind-password.age` | `authelia.nix` | Password for the `authelia_bind` LLDAP user |
| `authelia-oidc-client-<app>-hash.age` | `authelia.nix` | PHC-hashed client secret per OIDC app (grafana / immich / nextcloud / jellyfin). Plaintext is entered into each app's UI. |
| `grafana-oidc-client-secret.age` | `grafana.nix` | Plaintext OIDC secret for Grafana (env-injected into `GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET`) |

---

### `htpc` — living-room media client (Intel QSV)

Plays media from `server` (Jellyfin / SMB), hardware-accelerated via Intel iGPU.

**Hardware**
- GPU: Intel integrated. Userspace: `intel-media-driver` (VA-API / iHD),
  `vpl-gpu-rt` (oneVPL / QSV runtime). X driver: `modesetting`.
- Bluetooth: on, powers up at boot
- Input: libinput (in case of trackpad-equipped remote)
- Kernel: `linuxPackages_latest`
- Boot quirk: `initrd.systemd.tpm2.enable = false` (TPM2-in-initrd broke boot; leave off unless re-tested)

**Composition**
- NixOS: see `hosts/htpc/default.nix`
- Home-manager (`users/jrh/home/htpc.nix`): `common.nix` + `desktop-environment.nix`

**Functionality**
- KDE Plasma (couch-friendly)
- Hardware video acceleration (VA-API + QSV) — required for smooth 4K / HEVC from Jellyfin
- SMB **client** (mounts `server` shares)
- SSH server, GnuPG agent, Tailscale

**Networking** — Tailscale client; LAN port 22 (SSH).

**Secrets** — none directly.
