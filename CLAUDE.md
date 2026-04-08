# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands are run via `just` from the repo root:

| Command | Description |
|---|---|
| `just build` | Rebuild and switch the current host (`nixos-rebuild switch --flake '.#'`) |
| `just dry` | Dry-build and dry-activate to verify the flake compiles without applying |
| `just fmt` | Format all `.nix` files with `nixfmt` |
| `just lint` | Lint all `.nix` files with `statix` |
| `just up` | Update all flake inputs (`nix flake update`) |
| `just gc` | Garbage collect nix store entries older than 7 days |
| `just clean` | Wipe system profile generations older than 7 days |
| `just repl` | Open a nix repl scoped to the flake |

To build a specific host: `sudo nixos-rebuild switch --flake '.#<hostname>'`
Hosts: `laptop`, `desktop`, `server`, `htpc`

## Architecture

### Flake structure

`flake.nix` is the entry point. It defines four `nixosConfigurations` (`laptop`, `desktop`, `server`, `htpc`). The server uses stable nixpkgs (`nixos-25.11`); all other hosts use `nixos-unstable`. Each host receives a set of `specialArgs` (`username`, `system`, `inputs`, and feature flags) threaded through to every module.

Feature flags passed via `specialArgs`:
- `desktop-environment` — enables KDE, browser, graphical apps
- `game-streaming-client` / `game-streaming-server` — game streaming modules
- `emulation` — emulation packages

### Module layers

**NixOS modules** (`modules/nixos/`) are system-level and imported directly into host configs. Every host imports `common.nix` (user account, nix settings, firewall off, base packages, tailscale, fonts).

**Home-manager modules** (`modules/home-manager/`) are user-level. All hosts get the base set (bash, git, nixvim, tmux, cli tools). Desktop hosts additionally get browser, KDE, graphical apps, and terminal via `lib.optionals desktop-environment`.

**Host configs** (`hosts/<name>/default.nix`) compose modules for that machine. They contain minimal host-specific settings (hostname, stateVersion, hardware flags) and an `imports` list.

### Secrets (agenix)

Encrypted secrets live in `secrets/*.age`. The decryption key registry is `secrets.nix` at the **repo root** (not inside `secrets/`) — agenix requires this for the CLI to work (`agenix -e secrets/<file>.age` from repo root).

`modules/nixos/agenix.nix` installs the agenix CLI package on each host. Each module that needs a secret declares it via `age.secrets.<name>.file = ...` pointing into `secrets/`.

### Server services

The server runs a self-hosted media/automation stack, all defined as individual modules in `modules/nixos/`:

- **Media**: `jellyfin.nix`, `navidrome.nix`, `immich.nix`
- **Arr stack**: `radarr.nix`, `sonarr.nix`, `lidarr.nix`, `prowlarr.nix`
- **Requests**: `jellyseerr.nix`
- **Downloads**: `qbittorrent.nix` — traffic kill-switched to `tailscale0` via nftables; web UI only on tailscale (port 8080)
- **Reverse proxy**: `nginx.nix` — HTTPS via Tailscale cert (`server_name _` catch-all), exposed only on `tailscale0:443`. Tailscale hostname read at runtime from agenix secret. LAN-accessible services (Jellyfin, Navidrome, Jellyseerr, Homepage) remain on their original ports via `openFirewall = true`.
- **Dashboard**: `homepage-dashboard.nix`

### Storage layout

The server has two ZFS pools:
- `fasttank` — fast storage, used for container data (config, cache, DBs). Soon to be decommissioned in favor of tank pool.
- `tank` — bulk storage, used for media, backups, downloads, user files

New service data dirs go under `tank/applications/` (e.g. `dataDir = "/tank/applications/radarr"`). ZFS datasets are declared in `hosts/server/hardware-configuration.nix` as `fileSystems` entries — add new datasets there rather than creating them via systemd services.

### Nixvim

Neovim is configured via nixvim across several files:
- `nixvim.nix` — top-level: options, colorscheme, plugins
- `nixvim_keymaps.nix` — all keybindings (leader = `<Space>`)
- `nixvim_completions.nix` — completion sources
- `nixvim_plugins/` — one file per plugin

All `:command` style keymap actions require `<CR>`. Raw key sequences (e.g. `<C-w>h`) and plugin action names (fzf-lua) do not.
