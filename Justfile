### Justfile for nix operations
### https://github.com/ryan4yin/nix-config/blob/main/Justfile

# List all the just commands
default:
    @just --list

# Update all the flake inputs
[group('nix')]
up:
  nix flake update

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  #nix repl -f flake:nixpkgs
  nix repl .

# Remove all system generations older than 7 days
[group('nix')]
clean:
  # Wipe out NixOS's history
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
  # Wipe out home-manager's history
  #nix profile wipe-history --profile $"($env.XDG_STATE_HOME)/nix/profiles/home-manager" --older-than 7d

# Garbage collect all unused nix store entries older than 7 days
[group('nix')]
gc:
  # garbage collect all unused nix store entries(system-wide)
  sudo nix-collect-garbage --delete-older-than 7d
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

# Format all nix files
[group('nix')]
fmt:
  find . -name \*.nix -exec nixfmt {} \;

# Lint all nix files
[group('nix')]
lint:
    statix check .

# Use dry-build and dry-activate options to check flake builds properly
[group ('nix')]
dry:
  sudo nixos-rebuild dry-build --flake '.#' --show-trace
  sudo nixos-rebuild dry-activate --flake '.#' --show-trace

# Rebuild your system, activate the new generation immediately and make it the default boot option
[group ('nix')]
build:
  sudo nixos-rebuild switch --flake '.#'

# Verify all the store entries
[group('nix')]
verify-store:
  # Nix Store can contains corrupted entries if the nix store object has been modified unexpectedly.
  # This command will verify all the store entries,
  # and we need to fix the corrupted entries manually via `sudo nix store delete <store-path-1> <store-path-2> ...`
  nix store verify --all

# Repair Nix Store Objects
#[group('nix')]
#repair-store *paths:
#  nix store repair {{paths}}

###
### TODO: Remote builds
###

## Remotely rebuild the server host
#[group('build')]
#build-server:
#  nixos-rebuild --flake .#server --build-host jrh@server --target-host jrh@server --sudo switch
#
## Remotely rebuild the laptop host
#[group('build')]
#build-laptop:
#  nixos-rebuild --flake .#laptop --build-host jrh@laptop --target-host jrh@laptop --use-remote-sudo switch
#
## Remotely rebuild the desktop host
#[group('build')]
#build-desktop:
#  nixos-rebuild --flake .#desktop --build-host jrh@desktop --target-host jrh@desktop --use-remote-sudo switch
