# hosts/laptop/default.nix
{ pkgs, ... }:
{

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    # Garbage Collection
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  # Set Time zone
  time.timeZone = "America/Los_Angeles";

  users.users.jrh = {
    name = "jrh";
    home = "/Users/jrh";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #syntaxHighlighting.enable = true;
    #fzfCompletion.enable = true;
    #fzfHistory.enable = true;
  };

  programs = {
    info.enable = true;
    man.enable = true;
    gnupg = {
      agent = {
        enable = true;
		enableSSHSupport = true;
      };
    };
  };

  ###
  ### Darwin specific settings
  ###

  #Enable Touch ID for sudo
  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    global = {
      brewfile = true;
      autoUpdate = true;
    };
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    taps = [
      "homebrew/services"
    ];
    casks = [
    # Browsers
      "firefox"
      "brave-browser"
    # Terminal
      #"alacritty"
      "iterm2"
    # Cloud Storage
      #"syncthing"
    # Development
      "github"
      "visual-studio-code"
      "docker"
    # Productivity
      "ticktick"
      "notion"
      "copilot"
    # Entertainment
      "spotify"
    # Communication
      "whatsapp"
      "discord"
    # Utilities
      "flux"
      "hiddenbar"
      "rectangle"
      "tailscale"
      "moonlight"
      "hammerspoon"
    ];
    brews = [
      #"font-hack-nerd-font"
      "mas"
    ];
    masApps = {
      Bitwarden = 1352778147;
      GarageBand = 682658836;
      Pages = 409201541;
      Keynote = 409183694;
      Numbers = 409203825;
      Xcode = 497799835;
    };
  };

  networking = {
    computerName = "laptop";
    hostName = "laptop";
  };

  documentation = {
    enable = true;
    man.enable = true;
    doc.enable = true;
    info.enable = true;
  };

system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      alf.loggingenabled = 1;
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "WhenScrolling";
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.1;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = false;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        CreateDesktop = false;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };
      trackpad = {
        ActuationStrength = 0;
        Clicking = true;
	    Dragging = false;
	    TrackpadThreeFingerDrag = true;
		FirstClickThreshold = 0;
		SecondClickThreshold = 1;
		TrackpadRightClick = true;
      };
      dock = {
        autohide = false;
        autohide-delay = 0.24;
        autohide-time-modifier = 2.0;
        expose-animation-duration = 0.1;
        expose-group-by-app = false;
        launchanim = false;
        orientation = "bottom";
        show-recents = false;
        tilesize = 64; #48 or 64
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
	persistent-apps = [
          "/System/Library/coreServices/Finder.app"
	  "/Applications/Launchpad.app"
	  "/Applications/Messages.app"
	  "/Applications/Mail.app"
	  "/Applications/Maps.app"
	  "/Applications/Photos.app"
	  "/Applications/FaceTime.app"
	  "/Applications/Contacts.app"
	  "/Applications/Calendar.app"
	  "/Applications/Notes.app"
	  "/Applications/Podcasts.app"
	  "/Applications/Home.app"
	  "/Applications/Shortcuts.app"
	  "/Applications/System Settings.app"
	  "/Applications/Brave.app"
	  "/Applications/iTerm.app"
	  "/Applications/TickTick.app"
	  "/Applications/Notion.app"
	  "/Applications/WhatsApp.app"
	];
      };

      smb = {
        NetBIOSName = "laptop";
	ServerDescription = "laptop";
      };
      loginwindow = {
        GuestEnabled = false;
      };
      menuExtraClock = {
        ShowAMPM = true;
	ShowDate = 1;
	ShowDayOfWeek= true;
        ShowSeconds = false;
      };
      universalaccess = {
        mouseDriverCursorSize = 1.3;
	reduceMotion = true;
	reduceTransparency = false;
      };
    };
  };
    
}

