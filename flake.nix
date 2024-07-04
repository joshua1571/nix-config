{
  description = "JRH flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # Nix Darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
  #let
  #  configuration = { pkgs, ... }: {
  #    # List packages installed in system profile. To search by name, run:
  #    # $ nix-env -qaP | grep wget
  #    #environment.systemPackages =
  #    #  [ pkgs.vim
  #    #  ];

  #    # Auto upgrade nix package and the daemon service.
  #    services.nix-daemon.enable = true;
  #    # nix.package = pkgs.nix;

  #    # Necessary for using flakes on this system.
  #    nix.settings.experimental-features = "nix-command flakes";

  #    ## Create /etc/zshrc that loads the nix-darwin environment.
  #    #programs.zsh.enable = true;  # default shell on catalina
  #    ## programs.fish.enable = true;

  #    # Set Git commit hash for darwin-version.
  #    system.configurationRevision = self.rev or self.dirtyRev or null;

  #    # Used for backwards compatibility, please read the changelog before changing.
  #    # $ darwin-rebuild changelog
  #    system.stateVersion = 4;

  #    ## The platform the configuration will be used on.
  #    #nixpkgs.hostPlatform = "x86_64-darwin";
  #  };
  #in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#laptop
    darwinConfigurations."laptop" = nix-darwin.lib.darwinSystem {
      #modules = [ configuration ];

      system = "x86_64-darwin";
      modules = [ 
        home-manager.darwinModules.home-manager 
        ./hosts/laptop/default.nix 
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."laptop".pkgs;
  };
}
