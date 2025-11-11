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

    #TODO: Modularize flake
    #flake-parts = {
    #  url = "github:hercules-ci/flake-parts";
    #  inputs.nixpkgs-lib.follows = "nixpkgs";
    #};

    #TODO: replace neovim with nixvim
    # nixvim (unstable)
    #nixvim = {
    #  url = "github:nix-community/nixvim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #TODO: add secrets using age
    #agenix = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #TODO: Replace regular pkgs plasma with plasma manager
    #plasma-manager = {
    #  url = "github:nix-community/plasma-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "home-manager";
    #};

    #TODO: Configure disks in nix config
    #disko = {
    #  url = "github:nix-community/disko";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
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
        specialArgs = { inherit username; };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";

        modules = [
          ./hosts/desktop/default.nix

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
