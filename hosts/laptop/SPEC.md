# laptop

## Purpose

Portable personal workstation. Used for development on the move and as a
game-streaming *client* (receives streams from `desktop`).

## Hardware

- CPU: _TODO: fill in model_
- GPU: _TODO: integrated / discrete?_
- RAM: _TODO_
- Storage: LUKS-encrypted root (see `hardware-configuration.nix`)
- Network:
  - Wifi: MediaTek mt7921e (ASPM disabled via `extraModprobeConfig` to
    work around stability issues)
  - Wired: _TODO_
- Bluetooth: enabled, powers on at boot
- Input: touchpad (libinput)
- Kernel: `linuxPackages_latest`

## Composition

NixOS modules — see `hosts/laptop/default.nix` `imports` list.

Home-manager modules — see `users/jrh/home/laptop.nix`:

- `common.nix` (always-on bundle: bash, cli, git, nixvim, services, tmux)
- `desktop-environment.nix` (browser, graphical apps, KDE packages, terminal, local AI client)
- `pkgs.moonlight-qt` (game-streaming client)

## Functionality (desired state)

- KDE Plasma desktop
- Personal user account `jrh` (from `common.nix`)
- SSH server (for incoming admin access)
- GnuPG agent
- OBS Studio (screen recording / streaming)
- SMB **client** to mount shares from `server`
- Game-streaming client (receives from `desktop`)
- Tailscale connectivity (from `common.nix`)

## Networking

- Tailscale: client member of the tailnet
- LAN-exposed ports: SSH (22)
- Tailscale-only ports: none beyond defaults

## Secrets (agenix)

None required directly by laptop-specific modules. Inherits whatever
`common.nix` and `agenix.nix` set up.

## Known gaps / TODO

- Fill in concrete hardware model numbers above.
- Decide whether Mullvad / nextcloud client should run here.
- Document any host-specific home-manager state (wallpapers, KDE layout).
