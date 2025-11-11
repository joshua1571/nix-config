{
  description = "JRH NixOS Flake";

  inputs = {
    # Nixpkgs (unstable)
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    # Home manager (unstable)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Modularize flake using flake-parts
    #flake-parts = {
    #  url = "github:hercules-ci/flake-parts";
    #  inputs.nixpkgs-lib.follows = "nixpkgs";
    #};

    # TODO: Replace neovim with nixvim
    # nixvim (unstable)
    #nixvim = {
    #  url = "github:nix-community/nixvim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # TODO: Add secrets using age
    # TODO: Add ssh keys to user
    #agenix = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # TODO: Replace regular nixpkgs plasma with plasma manager
    #plasma-manager = {
    #  url = "github:nix-community/plasma-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "home-manager";
    #};

    # TODO: Configure disks declaratively in nix config
    #disko = {
    #  url = "github:nix-community/disko";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # TODO: Rebuild to change hostname: sudo nixos-rebuild switch --flake .#laptop
      laptop = let
        username = "jrh";
        specialArgs = { inherit username; };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64_linux";

        modules = [
          ./hosts/laptop/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = inputs // specialArgs;
              users.${username} = import ./users/${username}/home.nix;
            };
          }
        ];
      };

      desktop = let
        username = "jrh";
        emulation = true;
        specialArgs = {
          inherit username;
          inherit emulation;
        };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";

        modules = [
          ./hosts/desktop/default.nix
          # TODO: Add openrgb support: https://github.com/Misterio77/nix-config/blob/main/modules/nixos/openrgb.nix
          # TODO: Add emulation support

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = inputs // specialArgs;
              users.${username} = import ./users/${username}/home.nix;
            };
          }
        ];
      };

    };
  };
}
