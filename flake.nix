{
  description = "JRH NixOS Flake";

  inputs = {
    # Latest stable branch of nixpkgs, used for version rollback
    # The current latest version is 25.11
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };

    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-unstable = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # TODO High Priority: Add secrets using age
    # TODO: Add ssh keys to user
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    agenix-unstable = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.darwin.follows = "";
    };

    # TODO Low Priority: Set up colmena
    # Remote deployments
    colmena = {
      url = "github:zhaofengli/colmena";
    };

    # TODO Low Priority: Add disks from server using disko
    ## Configure disks declaratively in nix config
    #disko = {
    #  url = "github:nix-community/disko";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # TODO Low Priority: Add raspberry pi to flake
    ## Used for raspberry pi
    #nixos-hardware = {
    #  url = "github:NixOS/nixos-hardware";
    #};

    # TODO Low Priority: Modularize flake using flake-parts
    #flake-parts = {
    #  url = "github:hercules-ci/flake-parts";
    #  inputs.nixpkgs-lib.follows = "nixpkgs";
    #};

    # TODO Low Priority: Replace regular nixpkgs plasma with plasma manager
    # Try wayland based tiling window manager first
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
      nixpkgs-unstable,
      home-manager,
      home-manager-unstable,
      #nixos-hardware,
      agenix,
      agenix-unstable,
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
          nixpkgs-unstable.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./hosts/laptop/default.nix
              agenix-unstable.nixosModules.default

              home-manager-unstable.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home.nix;
                  backupFileExtension = "hm_backup";
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
          nixpkgs-unstable.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./hosts/desktop/default.nix
              agenix-unstable.nixosModules.default

              home-manager-unstable.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home.nix;
                  backupFileExtension = "hm_backup";
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
            system = "x86_64-linux";

            modules = [
              ./hosts/server/default.nix
              agenix.nixosModules.default

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home.nix;
                  backupFileExtension = "hm_backup";
                };
              }
            ];
          };

        htpc =
          let
            username = "jrh";
            emulation = false;
            desktop-environment = true;
            game-streaming-client = false;
            game-streaming-server = false;
            specialArgs = {
              inherit username;
              inherit emulation;
              inherit desktop-environment;
              inherit game-streaming-client;
              inherit game-streaming-server;
            };
          in
          nixpkgs-unstable.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./hosts/htpc/default.nix
              agenix.nixosModules.default

              home-manager-unstable.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home.nix;
                  backupFileExtension = "hm_backup";
                };
              }
            ];
          };
      };
    };
}
