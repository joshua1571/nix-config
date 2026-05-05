# htpc

## Purpose

Living-room media client. Plays media from `server` (Jellyfin / SMB),
hardware-accelerated via Intel iGPU.

## Hardware

- CPU: Intel (model _TODO_) — iGPU used for video decode
- GPU: Intel integrated. Userspace stack:
  - `intel-media-driver` (VA-API / iHD)
  - `vpl-gpu-rt` (oneVPL / QSV runtime)
  - X driver: `modesetting`
- RAM: _TODO_
- Storage: see `hardware-configuration.nix`
- Network: _TODO — wired ethernet preferred for streaming_
- Bluetooth: enabled, powers on at boot
- Input: libinput (in case a touchpad / trackpad-equipped remote is used)
- Kernel: `linuxPackages_latest`
- Boot quirk: `initrd.systemd.tpm2.enable = false` (disabled because TPM2
  in initrd caused boot issues — leave off unless re-tested)

## Composition

NixOS modules — see `hosts/htpc/default.nix` `imports` list.

Home-manager modules — see `users/jrh/home/htpc.nix`:

- `common.nix` (always-on bundle: bash, cli, git, nixvim, services, tmux)
- `desktop-environment.nix` (browser, graphical apps, KDE packages, terminal, local AI client)

## Functionality (desired state)

- KDE Plasma desktop (couch-friendly)
- Hardware video acceleration (VA-API + QSV) — required for smooth
  4K / HEVC playback from Jellyfin
- SMB **client** to mount shares from `server`
- SSH server, GnuPG agent
- Tailscale connectivity

## Networking

- Tailscale: client member of the tailnet
- LAN-exposed ports: SSH (22)

## Secrets (agenix)

None required directly.

## Known gaps / TODO

- Fill in CPU/GPU model (matters for QSV codec support matrix).
- Consider enabling `game-streaming-client` so the living room can
  receive streams from `desktop`.
- Consider auto-launching Jellyfin Media Player or a kiosk session on
  boot.
- Revisit `initrd.systemd.tpm2.enable = false` once root cause known.
