{
  username,
  ...
}:

{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  imports = [
    ../../../modules/home-manager/bash.nix
    ../../../modules/home-manager/cli_applications.nix
    ../../../modules/home-manager/git.nix
    ../../../modules/home-manager/nixvim.nix
    ../../../modules/home-manager/services.nix
    ../../../modules/home-manager/tmux.nix
  ];
}
