# cd ~/Development/GitHub/nix-config
# nix flake update
# sudo nixos-rebuild switch --flake /home/jrh/Development/GitHub/nix-config

# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix = {
    gc.automatic = true;
    gc.dates = "04:00";
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=1
  '';

  networking.hostName = "nixos"; # Define hostname
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  fileSystems."/home/jrh/Share" = {
    device = "//storage-ts/share"; # Need tailscale to be running on storage for mount to work properly, storage-ts won't reply
    fsType = "cifs";
    options =
      let

        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,uid=1000,gid=100,iocharset=utf8,x-systemd.requires=tailscaled.service";

      in
      [ "${automount_opts},credentials=/home/jrh/.samba/credentials" ];
  };

  hardware.graphics.enable = true;

  services.libinput.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  ###############################################################################
  ### Services
  ###############################################################################
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  # TODO: Configure syncthing
  ###services.syncthing.enable = false;
  ###services.opensnitch.enable = true;
  # services.openssh.enable = true;
  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;

  # KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Fonts
  fonts.enableDefaultPackages = true;
  fonts.fontconfig.useEmbeddedBitmaps = true;
  fonts.packages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix
    nerd-fonts.sauce-code-pro
    nerd-fonts.hack
    fira-code # for use with wezterm
  ];

  ###############################################################################
  ### User (move to home-manager)
  ###############################################################################
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jrh = {
    isNormalUser = true;
    description = "Joshua Hernandez";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
    ];
  };
  ###  packages = with pkgs; [
  ###    # KDE Specific Packages
  ###    kdePackages.yakuake
  ###    kdePackages.partitionmanager
  ###    #kdePackages.kamoso #Error: Marked broken in nixpkgs
  ###    kdePackages.filelight
  ###    kdePackages.kcalc
  ###    kdePackages.koko
  ###    kdePackages.ksshaskpass
  ###    kdePackages.kwallet
  ###    kdePackages.kwallet-pam
  ###    kdePackages.plasma-disks
  ###    kdePackages.plasma-browser-integration
  ###    kdePackages.xdg-desktop-portal-kde
  ###    kdePackages.sddm-kcm
  ###    kdePackages.wayland
  ###    kdePackages.wayland-protocols

  ###    # General Applications
  ###    wezterm
  ###    spotify
  ###    discord
  ###    obsidian
  ###    ticktick
  ###    dropbox
  ###    ktailctl
  ###    brave
  ###    bitwarden-desktop
  ###    github-desktop
  ###    libreoffice-qt6
  ###    deskflow

  ###    # Extra Applications
  ###    opensnitch
  ###    opensnitch-ui

  ###    #Development
  ###    vscode
  ###    pass

  ###    # Command Line Applications
  ###    xdg-utils
  ###    curl
  ###    nmap
  ###    aria2
  ###    yazi
  ###    tmux
  ###    ncspot
  ###    fzf
  ###    eza
  ###    bat
  ###    ripgrep
  ###    cheat
  ###    direnv
  ###    wget
  ###    ffmpeg
  ###    gh
  ###    aerc
  ###    mpv
  ###    trash-cli
  ###    ddgr
  ###    chezmoi

  ###    nixfmt # better in a dev shell
  ###    zathura
  ###    rclone
  ###    yt-dlp
  ###    beets
  ###    buku
  ###  ];


  ###############################################################################
  ### Programs
  ###############################################################################
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    lm_sensors
    cifs-utils
    file
    pciutils
    usbutils
  ];

  ###programs.firefox.enable = true;
  ###programs.git.enable = true;
  ###programs.git.prompt.enable = true;
  ###programs.mosh.enable = true;
  ###programs.neovim = {
  ###  enable = true;
  ###  viAlias = true;
  ###  vimAlias = true;
  ###  defaultEditor = true;
  ###  configure = {
  ###    customRC = ''
  ###      	    set showmatch               " show matching
  ###              set ignorecase              " case insensitive
  ###      	    set hlsearch                " highlight search
  ###              set incsearch               " incremental search
  ###              set tabstop=4               " number of columns occupied by a tab
  ###              set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
  ###              set expandtab               " converts tabs to white space
  ###              set shiftwidth=4            " width for autoindents
  ###              set autoindent              " indent a new line the same amount as the line just typed
  ###              set number    		        " add line numbers
  ###              set relativenumber          " add relative line numbers
  ###      	    set wildmode=longest,list   " get bash-like tab completions
  ###              set cc=80                   " set an 80 column border for good coding style
  ###              filetype plugin indent on   " allow auto-indenting depending on file type
  ###              syntax on                   " syntax highlighting
  ###              set mouse=a                 " enable mouse click
  ###      	    set clipboard=unnamedplus   " using system clipboard
  ###              set cursorline              " highlight current cursorline
  ###              set ttyfast                 " Speed up scrolling in Vim
  ###              filetype plugin on
  ###              let mapleader = " "         " Change leader key to spacebar
  ###              highlight Normal guibg=none
  ###              highlight NonText guibg=none
  ###              highlight Normal ctermbg=none
  ###              highlight NonText ctermbg=none
  ###    '';
  ###    packages.myVimPackage = with pkgs.vimPlugins; {
  ###      # loaded on launch
  ###      start = [
  ###        fugitive
  ###        nerdtree
  ###        vim-devicons
  ###      ];
  ###      # manually loadable by calling `:packadd $plugin-name`
  ###      opt = [ ];
  ###    };
  ###  };
  ###};

  ###programs.partition-manager.enable = true;
  ###programs.bash.completion.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  ###programs.mtr.enable = true;
  ###programs.gnupg.agent = {
  ###  enable = true;
  ###  enableSSHSupport = true;
  ###};

  # Automatic upgrades
  #system.autoUpgrade.enable = true;
  #system.autoUpgrade.allowReboot = false;

  ### System
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # NOT SUPPORTED WITH FLAKES
  #system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
