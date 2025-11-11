{ config, pkgs, username, ... }:

{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  imports = [
    # What is the best way to separate modules?
    ../../homeManagerModules/bash.nix
    ../../homeManagerModules/browser.nix
    ../../homeManagerModules/cli_applications.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/graphical_applications.nix
    ../../homeManagerModules/kde_packages.nix
    ../../homeManagerModules/neovim.nix
    ../../homeManagerModules/services.nix
    ../../homeManagerModules/terminal.nix
    ../../homeManagerModules/tmux.nix
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
