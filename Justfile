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

# Rebuild your system, activate the new generation immediately and make it the default boot option
[group ('build')]
build:
  sudo nixos-rebuild switch --flake '.#'

### TODO: Remote builds
# Remotely rebuild the htpc host
[group('build')]
build-htpc:
  NIX_SSHOPTS="-p 2228" nixos-rebuild --flake .#htpc --target-host jrhassistant@htpc --use-remote-sudo switch


# Attempt to build flake for all configurations
[group('checks')]
check:
  nix flake check --no-build --show-trace

# Check formatting on all code
[group('checks')]
fmt:
  #find . -name \*.nix -exec nixfmt {} \;
  nix shell nixpkgs#nixfmt -c sh -c \
    'find . -name "*.nix" ! -path "./.git/*" | xargs nixfmt --check'

# Lint all code
[group('checks')]
lint:
  nix run nixpkgs#statix -- check .

# Check for dead code still present in the repo
[group('checks')]
dead:
  nix run nixpkgs#deadnix -- --fail .



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


