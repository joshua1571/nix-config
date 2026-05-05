# desktop

## Purpose

Primary workstation. Doubles as a game-streaming *server* (streams to
`laptop`) and runs emulation and a local AI inference server.

## Hardware

- CPU: AMD Ryzen 9 5900X
- GPU: AMD Radeon RX 6800 XT
- RAM: 64 GB
- Storage:
  - Root: see `hardware-configuration.nix`
  - Games disk: managed by `modules/nixos/games_disk.nix`
  - Windows disk: not managed by flake (/dev/sda, 256GB)
- Network:
  - Wifi: MediaTek mt7921e (ASPM disabled via `extraModprobeConfig`)
  - Wired: Realtek RTL8125 2.5GbE Controller (rev 05)
- Bluetooth: enabled, powers on at boot
- Kernel: `linuxPackages_latest`
- Peripherals: 
  - Keyboard: Ducky One 2 Mini
  - Mouse: Glorious Model D Wireless
  - Audio: Taotronics TT-BA014
  - Microphone: Sennheiser Profile
  - Controller: Gamesir Cyclone 2

## Composition

NixOS modules — see `hosts/desktop/default.nix` `imports` list.

Home-manager modules — see `users/jrh/home/desktop.nix`:

- `common.nix` (always-on bundle: bash, cli, git, nixvim, services, tmux)
- `desktop-environment.nix` (browser, graphical apps, KDE packages, terminal, local AI client)
- `pkgs.ryubing` (Nintendo Switch emulator)

## Functionality (desired state)

- KDE Plasma desktop
- Steam + game-streaming server (Sunshine/Moonlight, see streaming module)
- Emulation suite (ryubing via home-manager)
- Local AI inference server (`local_ai_server.nix`)
- Dedicated games disk mount
- OBS Studio
- SMB **client** to mount shares from `server`
- SSH server, GnuPG agent
- Tailscale connectivity

## Networking

- Tailscale: client member of the tailnet

## Secrets (agenix)

None required directly. Inherits common setup.

## Known gaps / TODO

- `openrgb.nix` does not see RAM rgb lights
- Document the games disk device path / filesystem.
