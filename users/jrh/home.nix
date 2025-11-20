{
  lib,
  config,
  username,
  game-streaming-server,
  game-streaming-client,
  desktop-environment,
  ...
}:

{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  imports = [
    # What is the best way to separate modules?
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/cli_applications.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/nixvim.nix
    ../../modules/home-manager/services.nix
    ../../modules/home-manager/tmux.nix
  ]
  ++ lib.optionals desktop-environment [
    ../../modules/home-manager/browser.nix
    ../../modules/home-manager/graphical_applications.nix
    ../../modules/home-manager/kde_packages.nix
    ../../modules/home-manager/terminal.nix
  ];
  #++ lib.optionals game-streaming-client [
  #++ lib.optionals game-streaming-server [
  #  ../../modules/home-manager/game-streaming-server.nix
  #]
  #++ lib.optionals game-streaming-client [
  #  ../../modules/home-manager/game-streaming-client.nix
  #];
  #++ lib.optionals ai_host [
  #  ../../modules/home-manager/ai.nix
  #];

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
