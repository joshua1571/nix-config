{
  description = "JRH NixOS Flake";

  inputs = {
    # Latest stable branch of nixpkgs, used for version rollback
    # The current latest version is 25.11
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };

    #nixpkgs-unstable = {
    #  url = "github:nixos/nixpkgs/nixos-unstable";
    #};

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #home-manager-unstable = {
    #  url = "github:nix-community/home-manager";
    #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixvim-unstable = {
    #  url = "github:nix-community/nixvim";
    #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    #agenix-unstable = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    #  inputs.darwin.follows = "";
    #};

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      agenix,
      ...
    }:
    {
      nixosConfigurations = {
        laptop =
          let
            username = "jrh";
            system = "x86_64-linux";
            specialArgs = {
              inherit system;
              inherit inputs;
              inherit username;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system specialArgs;

            modules = [
              ./hosts/laptop/default.nix
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home/laptop.nix;
                  backupFileExtension = "hm_backup";
                };
              }
            ];
          };

        desktop =
          let
            username = "jrh";
            system = "x86_64-linux";
            specialArgs = {
              inherit system;
              inherit inputs;
              inherit username;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system specialArgs;

            modules = [
              ./hosts/desktop/default.nix
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home/desktop.nix;
                  backupFileExtension = "hm_backup";
                };
              }
            ];
          };

        server =
          let
            username = "jrh";
            system = "x86_64-linux";
            specialArgs = {
              inherit system;
              inherit inputs;
              inherit username;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit system specialArgs;

            modules = [
              ./hosts/server/default.nix
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = inputs // specialArgs;
                  users.${username} = import ./users/${username}/home/server.nix;
                  backupFileExtension = "hm_backup";
                };
              }
            ];
          };

        # Original host was removed. May change this to the new htpc host which is a mac mini
        #htpc =
        #  let
        #    username = "jrh";
        #    system = "x86_64-linux";
        #    specialArgs = {
        #      inherit inputs;
        #      inherit system;
        #      inherit username;
        #    };
        #  in
        #  nixpkgs-unstable.lib.nixosSystem {
        #    inherit system specialArgs;

        #    modules = [
        #      ./hosts/htpc/default.nix
        #      agenix-unstable.nixosModules.default
        #      home-manager-unstable.nixosModules.home-manager
        #      {
        #        home-manager = {
        #          useGlobalPkgs = true;
        #          useUserPackages = true;
        #          extraSpecialArgs = inputs // specialArgs;
        #          users.${username} = import ./users/${username}/home/htpc.nix;
        #          backupFileExtension = "hm_backup";
        #        };
        #      }
        #    ];
        #  };
      };
    };
}
