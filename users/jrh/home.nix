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
    kdePackages.partitionmanager
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
    userName = "Joshua Hernandez";
    userEmail = "joshua1571@users.noreply.github.com";
    delta.enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/.local/bin"
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      alias ll='exa --color=auto -l --git --git-repos -o -g ';
      alias l='ll';
      alias lla='exa --color=auto -l --git --git-repos -o -g -a';
      alias grep='rg --color=auto';
    };
  };
  programs.bat.enable = true;
  programs.firefox.enable = true;
  programs.aerc.enable = true;
  programs.zathura.enable = true;
  programs.fzf.enable = true;
  programs.eza = {
    enable = true;
    colors = auto;
    git = true;
    icons = auto;
  };
  programs.ripgrep.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

  };
  programs.ncspot.enable = true;
  #programs.beets.enable = true;
  #programs.mpd.enable = true;
  programs.mpv.enable = true;
  programs.aria2.enable = true;
  programs.aria2.settings = {
    dir=${HOME}/Downloads
  };
  programs.yazi.enable = true;
  programs.yazi.initlua = {
    [mgr]
    show_hidden = false
    sort_dir_first = true
    show_symlink = true
  };
  programs.wezterm.enable = true;
  programs.wezterm.extraConfig = ''
    -- Pull in the wezterm API
    local wezterm = require 'wezterm'
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

  '';
  
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = vi;
    mouse = true;
    prefix = "C-a";
    #TODO
    #extraConfig = ''
    #  
    #'';
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
