# server

## Purpose

Headless home-lab server. Runs the self-hosted media stack, the *arr
automation suite, photo backup, file sharing, and a Tailscale-fronted
reverse proxy. Holds bulk and fast storage for the household.

Uses **stable** nixpkgs (`nixos-25.11`) — all other hosts are unstable.

## Hardware

- CPU: _TODO: fill in model_
- GPU: integrated, used for Jellyfin transcoding (`hardware.graphics.enable = true`)
- RAM: _TODO_
- Storage:
  - `tank` — bulk ZFS pool (HDDs)
  - `fasttank` — fast ZFS pool (SSD/NVMe), used for `containers`
  - Root: see `hardware-configuration.nix`
- Network: _TODO — NIC model, link speed_

## Feature flags (`flake.nix`)

| Flag | Value | Reason |
|---|---|---|
| `desktop-environment` | `false` | Headless |
| `game-streaming-client` | `false` | n/a |
| `game-streaming-server` | `false` | n/a |
| `emulation` | `false` | n/a |

## Functionality (desired state)

### Media

- Jellyfin (`:8096`, LAN-exposed via `openFirewall`)
- Navidrome (LAN-exposed via `openFirewall`)
- Immich (`:2283`, LAN-exposed via `openFirewall`)

### *arr automation

- Radarr (LAN-exposed)
- Sonarr (LAN-exposed)
- Lidarr (LAN-exposed)
- Prowlarr (LAN-exposed)
- Jellyseerr (LAN-exposed)
- Flaresolverr (LAN-exposed)

### Downloads

- qBittorrent — `openFirewall = false`. All traffic kill-switched to
  `tailscale0` via nftables. Web UI on `:8080`, **Tailscale-only**.

### Reverse proxy

- nginx — HTTPS via Tailscale cert (`server_name _` catch-all),
  bound to `tailscale0:443` only. Tailscale hostname read at runtime
  from `secrets/tailscale-hostname.age`.
- LAN-accessible services keep their original ports via `openFirewall`.

### Dashboard

- Homepage Dashboard on `:8082`. Domain read from
  `secrets/tailscale-domain.age`.

### Other

- ZFS (`tank`, `fasttank`)
- SMB **server** (shares to LAN clients)
- Mullvad WireGuard (kill-switch / qBittorrent VPN — see secrets)
- SSH server, GnuPG agent

## Networking

- Tailscale: tailnet node, hostname registered in agenix secret
- LAN-exposed TCP ports: 22 (SSH), Jellyfin 8096, Navidrome (default),
  Immich 2283, Radarr/Sonarr/Lidarr/Prowlarr/Jellyseerr/Flaresolverr
  (defaults), Homepage 8082, SMB
- Tailscale-only TCP ports: 443 (nginx), 8080 (qBittorrent web UI)
- Mullvad WireGuard interface for qBittorrent

## Storage layout

Defined in `hosts/server/storage.nix` via `boot.zfs.extraPools` and
`systemd.tmpfiles.rules`. Native ZFS mountpoints — do **not** add these
datasets to `hardware-configuration.nix`.

`tank` (bulk):
- `tank/backups/{desktop,laptop,macbookpro}` — host backups
- `tank/media/{movies,tv,music,books,games}` — finished media
- `tank/media/torrents/*` — qBittorrent download dirs (per-arr ownership)
- `tank/media/usenet/*` — usenet incomplete + complete dirs
- `tank/personal/{photos,documents,downloads,development}` — personal files
- `tank/personal/photos/immich_data` — immich backing store

`fasttank` (fast):
- `fasttank/containers` — docker data root

## Secrets (agenix)

| Secret | Used by | Purpose |
|---|---|---|
| `tailscale-hostname.age` | `nginx.nix` | Tailscale cert hostname |
| `tailscale-domain.age` | `homepage-dashboard.nix` | Dashboard domain |
| `mullvad-wg-private-key.age` | `mullvad.nix` | WireGuard private key |
| `mullvad-wg-preshared-key.age` | `mullvad.nix` (commented) | WG preshared key |

## Known gaps / TODO

- Migrate disks to declarative `disko` config (low priority TODO in `flake.nix`).
- Migrate to `colmena` for remote deploys.
- Decide whether `home-assistant`, `nextcloud`, `syncthing` (modules
  exist but are not imported) should run here.
- Document the actual Tailscale hostname/domain values somewhere
  outside agenix (e.g. README) for human reference.
- Add backup strategy: who pulls from `tank/backups/*`, retention.
