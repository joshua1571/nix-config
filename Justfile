### Justfile for nix operations
### https://github.com/ryan4yin/nix-config/blob/main/Justfile

# List all the just commands
default:
    @just --list

# Update all the flake inputs
[group('build')]
up:
  nix flake update

# Attempt a dry build of the current host
[group ('build')]
dry:
  nixos-rebuild dry-build --flake '.#' --show-trace

# SUDO: Rebuild your system, activate the new generation immediately and make it the default boot option
[group ('build')]
build:
  sudo nixos-rebuild switch --flake '.#'

# Deploy a remote host over SSH via tailscale (builds on the target). Usage: just deploy server
[group ('build')]
deploy HOST:
  nixos-rebuild switch --flake '.#{{HOST}}' \
    --target-host jrh@{{HOST}} \
    --build-host jrh@{{HOST}} \
    --sudo

# Deploy a remote host with an interactive sudo password prompt (bootstrap or fallback when the passwordless sudo rule isn't active). Usage: just deploy-ask server
[group ('build')]
deploy-ask HOST:
  nixos-rebuild switch --flake '.#{{HOST}}' \
    --target-host jrh@{{HOST}} \
    --build-host jrh@{{HOST}} \
    --sudo \
    --ask-sudo-password

# Dry-run a remote deploy (build + activation script only, no switch). Usage: just deploy-dry server
[group ('build')]
deploy-dry HOST:
  nixos-rebuild dry-activate --flake '.#{{HOST}}' \
    --target-host jrh@{{HOST}} \
    --build-host jrh@{{HOST}} \
    --sudo

# Deploy to all remote hosts sequentially
[group ('build')]
deploy-all:
  just deploy laptop
  just deploy desktop
  just deploy server

# Attempt to build flake for all configurations
[group('checks')]
check:
  ./scripts/checks.sh flake-check

# Check formatting on all code
[group('checks')]
fmt:
  ./scripts/checks.sh fmt

#Format a file using nixfmt
[group('checks')]
fmt-file file:
	nix run nixpkgs#nixfmt -- {{file}}

# Lint all code
[group('checks')]
lint:
  ./scripts/checks.sh lint

# Check for dead code still present in the repo
[group('checks')]
dead:
  ./scripts/checks.sh dead

# Run all checks (same as CI and the pre-commit hook)
[group('checks')]
check-all:
  ./scripts/checks.sh all



# List all generations of the system profile
[group('cleanup')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# SUDO: Remove all system generations older than 7 days
[group('cleanup')]
clean-system:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Remove all home-manager generations older than 7 days
[group('cleanup')]
clean-home:
  nix profile wipe-history --profile "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager" --older-than 7d

# Garbage collect all unused nix store entries older than 7 days
[group('cleanup')]
gc-system:
  # garbage collect all unused nix store entries(system-wide)
  nix-collect-garbage --delete-older-than 7d

# Garbage collect all unused home-manager nix store entries older than 7 days
[group('cleanup')]
gc-home:
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d


