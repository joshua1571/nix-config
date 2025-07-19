# sudo nixos-rebuild switch --upgrade

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  #imports =
  #  [ # Include the results of the hardware scan.
  #    ./hardware-configuration.nix
  #  ];

  nix = {
    gc.automatic = true;
    gc.dates = "04:00";
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6 = {
    enable = true;
    #excludePackages = with pkgs.libsForQt5; [
    #elisa
    #];
  };

#  programs.hyprland = {
#    enable = true;
#    xwayland.enable = true;
#  };
#  services.hypridle.enable = true;
#  programs.hyprlock.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb = {
  #  layout = "us";
  #  variant = "";
  #};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable NerdFonts
  fonts.packages = with pkgs; [ #https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix
    nerd-fonts.sauce-code-pro
    nerd-fonts.hack
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jrh = {
    isNormalUser = true;
    description = "Joshua Hernandez";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
      # KDE Specific Packages
      kdePackages.yakuake
      kdePackages.partitionmanager
      kdePackages.kdenlive
      #kdePackages.kamoso #Error: Marked broken in nixpkgs
      kdePackages.filelight
      kdePackages.kcalc
      kdePackages.koko
      kdePackages.ksshaskpass
      kdePackages.plasma-disks
      kdePackages.plasma-browser-integration
      kdePackages.xdg-desktop-portal-kde
      kdePackages.sddm-kcm
      #kdePackages.wayland
      haruna
      krita

      ##Hyprland Specific Packages
      #kitty # Required terminal
      ##wofi # Program Launcher
      #rofi-wayland # Program Launcher
      #waybar # Status Bar
      #brightnessctl # Media keys - brightness control
      #mako # Notifications #dunst
      #wireplumber # Media keys - volume control
      #kdePackages.qt6ct
      #hyprpaper
      ## hyprcursor
      #hyprsunset
      #networkmanagerapplet
      ## fabric #https://github.com/Fabric-Development/fabric
      ## astal #https://github.com/aylur/astal

      # General Packages
      #qalculate-qt
      spotify
      discord
      obsidian
      ticktick
      dropbox
      kicad
      brave
      bitwarden-desktop
      whatsie
      moonlight-qt
      calibre
      github-desktop
      wireshark
      #gimp
      libreoffice-qt6
      activitywatch
      openrgb
      freecad-wayland
      drawio
      birdtray
      deskflow

      #Development
      vscode
      #vscode.fhs
      #vscode-with-extensions
      pass
      xdg-utils
#      vscode-extensions.asvetliakov.vscode-neovim
#      vscode-extensions.ms-python.vscode-pylance
#      vscode-extensions.ms-python.python
#      vscode-extensions.mkhl.direnv
#      vscode-extensions.ms-vscode-remote.remote-containers
#      vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
#      vscode-extensions.ms-vscode-remote.remote-ssh-edit
#      vscode-extensions.ms-vscode-remote.remote-ssh
#      vscode-extensions.redhat.ansible
#      vscode-extensions.ms-toolsai.jupyter
#      vscode-extensions.ms-toolsai.datawrangler
#      vscode-extensions.ms-toolsai.jupyter-renderers
#      vscode-extensions.ms-toolsai.jupyter-keymap
#      vscode-extensions.ms-azuretools.vscode-docker

      # Command Line Applications
      direnv
      eza
      bat
      ripgrep
      curl
      nmap
      aria2
      wget
      tmux
      nil # Nix LSP server
      fzf
      yazi
      mpv
      cmus
      beets
      #nchat
      #bitwarden-cli
      #pass-wayland
      yt-dlp 
      rclone
      #xplr
      ncspot
      ffmpeg
      #mosh
      dive
      #restic
      #cheat
      #calcurse
      #mutt
      #newsboat
      #age
      #beets
     
      #Not sure I want these yet
      digikam
      opensnitch
      opensnitch-ui
      blender
      inkscape
      projectlibre
      #waydroid
      #borgbackup
      #czkawka
    ];
  };

  programs.firefox.enable = true;
  #fonts.fontconfig.useEmbeddedBitmaps = true; #Noto Color Emoji doesn't render on Firefox
  programs.git.enable = true;
  programs.git.prompt.enable = true;
  programs.mosh.enable = true;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    configure = {
      customRC = ''
	    set showmatch               " show matching 
        set ignorecase              " case insensitive
	    set hlsearch                " highlight search 
        set incsearch               " incremental search
        set tabstop=4               " number of columns occupied by a tab 
        set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
        set expandtab               " converts tabs to white space
        set shiftwidth=4            " width for autoindents
        set autoindent              " indent a new line the same amount as the line just typed
        set number    		    " add line numbers
	    set wildmode=longest,list   " get bash-like tab completions
        set cc=80                  " set an 80 column border for good coding style
        filetype plugin indent on   "allow auto-indenting depending on file type
        syntax on                   " syntax highlighting
        set mouse=a                 " enable mouse click
	    set clipboard=unnamedplus   " using system clipboard
        set cursorline              " highlight current cursorline
        set ttyfast                 " Speed up scrolling in Vim
        filetype plugin on
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        # loaded on launch
        start = [ fugitive nerdtree vim-devicons ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [ ];
      };
    };
  };
  programs.partition-manager.enable = true;
  programs.steam.enable = true;
  programs.thunderbird.enable = true;
  programs.bash.completion.enable = true;
  programs.bash.shellAliases = { 
    ll = "exa --color=auto -l --git --git-repos -o -g -a";
    grep = "rg --color=auto";
    cat = "bat";
    ya = "yazi";
  };

#  virtualisation.containers.enable = true;
#  virtualisation = {
#    podman = {
#      enable = true;
#
#      # Create a `docker` alias for podman, to use it as a drop-in replacement
#      dockerCompat = true;
#
#      # Required for containers under podman-compose to be able to talk to each other.
#      defaultNetwork.settings.dns_enabled = true;
#    };
#  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
      rootless.enable = true;
      rootless.setSocketVariable = true;
    };
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     lm_sensors
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  ### Services
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";
  services.flatpak.enable = false;
  services.syncthing.enable = false;
  # Supporting flatpak service
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  #xdg.portal.config.common.default = "gtk";
  #systemd.services.flatpak-repo = {
  #  wantedBy = [ "multi-user.target" ];
  #  path = [ pkgs.flatpak ];
  #  #script = ''
  #  #  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #  #'';
  #};

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  ### Hardware
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];

  services.fwupd.enable = true;

  services.power-profiles-daemon.enable = true;
 # services.auto-cpufreq = {
 #   enable = true;
 #   settings = {
 #     battery = {
 #       governor = "powersave";
 #       turbo = "never";
 #     };
 #     charger = {
 #       governor = "performance";
 #       turbo = "auto";
 #     };
 #   };
 # };

  # Limit battery charging to 80%
  #hardware.asus.battery =
  #{
  #  chargeUpto             = 80;   # Maximum level of charge for your battery, as a percentage.
  #  enableChargeUptoScript = true; # Whether to add charge-upto to environment.systemPackages. `charge-upto 85` temporarily sets the charge limit to 85%.
  #};

  # Enable RGB keyboard support
  boot.kernelModules               = [ "i2c-dev" "i2c-piix4" ];
  hardware.i2c.enable              = true;
  services.udev.packages           = [ pkgs.openrgb ];
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";

  # Automatic upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  ### System
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
