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

### server

- Fill in hardware in `README.md`: CPU, RAM, NIC model + link speed.
- Decide whether `home-assistant` and `syncthing` (modules exist, unimported) should run here.
- Document actual Tailscale hostname/domain values outside agenix for human reference.
- Add backup strategy: who pulls from `tank/backups/*`, retention policy.

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
