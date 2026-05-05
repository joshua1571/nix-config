# desktop

## Purpose

Primary workstation. Doubles as a game-streaming *server* (streams to
`laptop`) and runs emulation and a local AI inference server.

## Hardware

- CPU: _TODO: fill in model_
- GPU: _TODO: discrete GPU model — relevant for Steam, streaming, local AI_
- RAM: _TODO_
- Storage:
  - Root: see `hardware-configuration.nix`
  - Games disk: managed by `modules/nixos/games_disk.nix`
- Network:
  - Wifi: MediaTek mt7921e (ASPM disabled via `extraModprobeConfig`)
  - Wired: _TODO_
- Bluetooth: enabled, powers on at boot
- Kernel: `linuxPackages_latest`
- Peripherals: _TODO — controllers, capture, OpenRGB devices?_

## Composition

NixOS modules — see `hosts/desktop/default.nix` `imports` list.

Home-manager modules — see `users/jrh/home/desktop.nix`:

- `common.nix` (always-on bundle: bash, cli, git, nixvim, services, tmux)
- `desktop-environment.nix` (browser, graphical apps, KDE packages, terminal, local AI client)
- `pkgs.ryubing` (emulation)

## Functionality (desired state)

- KDE Plasma desktop
- Steam + game-streaming server (Sunshine/Moonlight, see streaming module)
- Emulation suite (`emulation` flag)
- Local AI inference server (`local_ai_server.nix`)
- Dedicated games disk mount
- OBS Studio
- SMB **client** to mount shares from `server`
- SSH server, GnuPG agent
- Tailscale connectivity

## Networking

- Tailscale: client member of the tailnet
- LAN-exposed ports: SSH (22), game-streaming ports (per streaming module)
- Tailscale-only ports: none

## Secrets (agenix)

None required directly. Inherits common setup.

## Known gaps / TODO

- Fill in CPU/GPU/RAM details — important for `local_ai_server` sizing.
- `openrgb.nix` is currently commented out in `default.nix` — decide
  whether to enable.
- Document the games disk device path / filesystem.
- Decide whether to mirror nextcloud / immich client setup.
