{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jrh";
  home.homeDirectory = "/home/jrh";

  # Packages
  home.packages = with pkgs; [
    # KDE Specific Packages
    kdePackages.yakuake
    #kdePackages.partitionmanager #system package instead
    #kdePackages.kamoso #Error: Marked broken in nixpkgs
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.koko
    kdePackages.ksshaskpass
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.plasma-disks
    kdePackages.plasma-browser-integration
    kdePackages.xdg-desktop-portal-kde
    kdePackages.sddm-kcm
    kdePackages.wayland
    kdePackages.wayland-protocols

    # GUI Applications
    spotify
    discord
    obsidian
    ticktick
    ktailctl
    brave
    bitwarden-desktop
    github-desktop
    libreoffice-qt6
    deskflow
    opensnitch

    #Development
    #vscode
    #pass

    # Command Line Applications
    xdg-utils
    curl
    nmap
    zip
    xz
    unzip
    cheat
    wget
    ffmpeg
    gh
    trash-cli
    ddgr

    # Extra
    nixfmt # better in a dev shell
    rclone
  ];

  # Programs
  programs.git = {
    enable = true;
    settings.user.name = "Joshua Hernandez";
    settings.user.email = "joshua1571@users.noreply.github.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ll = "eza -l -o -g";
      lla = "eza -l -o -g -a";
      grep = "rg --color=auto";
      gits = "git status";
      gitd = "git diff";
      rm = "echo 'Use trash-put instead...'; false";
      tput = "trash-put";
      tlist = "trash-list";
      trestore = "trash-restore";
    };
  };

  programs.bat.enable = true;
  programs.firefox.enable = true;
  programs.aerc.enable = true;
  programs.zathura.enable = true;
  programs.fzf.enable = true;
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.eza = {
    enable = true;
    colors = "auto";
    git = true;
    icons = "auto";
  };

  programs.ripgrep.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

  };
  programs.ncspot.enable = true;
  programs.mpv.enable = true;
  programs.aria2.enable = true;
  programs.aria2.settings = {
    dir = "/home/jrh/Downloads";
  };
  programs.yazi.enable = true;
  programs.yazi.settings = {
    log = {
      enabled = false;
    };
    mgr = {
      show_hidden = false;
      sort_by = "mtime";
      sort_dir_first = true;
      sort_reverse = true;
      show_symlink = true;
    };
  };
  programs.wezterm.enable = true;
  programs.wezterm.extraConfig = ''
    -- Fonts and Colors
    config.font_size = 10
    config.font = wezterm.font 'Fira Code'
    config.harfbuzz_features = { 'zero', 'cv02', 'ss01', 'cv10', 'ss05', 'ss03', 'cv29' }
    config.color_scheme = 'Gruvbox dark, hard (base16)'
    -- Tab bar
    config.use_fancy_tab_bar = false
    config.tab_bar_at_bottom = false
    config.hide_tab_bar_if_only_one_tab = false
    -- cursor
    config.default_cursor_style = 'BlinkingBlock'
    config.animation_fps = 60
    config.hide_mouse_cursor_when_typing = true
    -- Window
    config.window_background_opacity = 0.8
    config.window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    }
    return config
  '';

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    #TODO
    #extraConfig = ''
    #
    #'';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = ''
      -- Basic settings
      vim.o.number = true -- Enable line numbers
      vim.o.relativenumber = true -- Enable relative line numbers
      vim.o.tabstop = 4 -- Number of spaces a tab represents
      vim.o.shiftwidth = 4 -- Number of spaces for each indentation
      vim.o.expandtab = true -- Convert tabs to spaces
      vim.o.smartindent = true -- Automatically indent new lines
      vim.o.wrap = false -- Disable line wrapping
      vim.o.cursorline = true -- Highlight the current line
      vim.o.termguicolors = true -- Enable 24-bit RGB colors

      -- Syntax highlighting and filetype plugins
      vim.cmd('syntax enable')
      vim.cmd('filetype plugin indent on')

      -- Leader key
      vim.g.mapleader = ' ' -- Space as the leader key
    '';
  };

  # Services
  services.dropbox.enable = true;
  services.opensnitch-ui.enable = true;
  services.gpg-agent.enable = true;

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
