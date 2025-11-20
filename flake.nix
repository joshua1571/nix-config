{
  description = "JRH NixOS Flake";

  inputs = {
    # Nixpkgs (unstable)
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    # Home manager (unstable)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for raspberry pi
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    # nixvim (unstable)
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # HIGH PRIORITY TODO: Add secrets using age
    # TODO: Add ssh keys to user
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # HIGH PRIORITY TODO: Configure disks declaratively in nix config
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Modularize flake using flake-parts
    #flake-parts = {
    #  url = "github:hercules-ci/flake-parts";
    #  inputs.nixpkgs-lib.follows = "nixpkgs";
    #};

    # TODO: Replace regular nixpkgs plasma with plasma manager
    # TODO: Try hyprland again first
    #plasma-manager = {
    #  url = "github:nix-community/plasma-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "home-manager";
    #};
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }:
    {
      nixosConfigurations = {
        laptop =
          let
            username = "jrh";
            emulation = false;
            desktop-environment = true;
            game-streaming-client = true;
            game-streaming-server = false;
            specialArgs = {
              inherit username;
              inherit emulation;
              inherit desktop-environment;
              inherit game-streaming-client;
              inherit game-streaming-server;
            };
          in
          nixpkgs.lib.nixosSystem {
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

        desktop =
          let
            username = "jrh";
            emulation = true;
            desktop-environment = true;
            game-streaming-client = false;
            game-streaming-server = true;
            specialArgs = {
              inherit username;
              inherit emulation;
              inherit desktop-environment;
              inherit game-streaming-client;
              inherit game-streaming-server;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./hosts/desktop/default.nix
              # TODO: Add openrgb support: https://github.com/Misterio77/nix-config/blob/main/modules/nixos/openrgb.nix

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

        server =
          let
            username = "jrh";
            emulation = false;
            game-streaming-client = false;
            game-streaming-server = false;
            desktop-environment = false;
            specialArgs = {
              inherit username;
              inherit emulation;
              inherit desktop-environment;
              inherit game-streaming-client;
              inherit game-streaming-server;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "aarch64-linux";

            modules = [
              nixos-hardware.nixosModules.raspberry-pi-4
              ./hosts/server/default.nix

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
