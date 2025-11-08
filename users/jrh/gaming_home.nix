{ config, pkgs, ... }:

{
  home = {
    username = "jrh";
    homeDirectory = "/home/jrh";

    # Packages
    packages = with pkgs; [
      # KDE Specific Packages
      kdePackages.yakuake
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

      # Command Line Applications
      xdg-utils
      nmap
      curl
      wget
      zip
      xz
      unzip
      trash-cli
      gh
      ddgr
      cheat
      rclone
    ];
  };

  # Programs
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Joshua Hernandez";
          email = "joshua1571@users.noreply.github.com";
        };
        core = {
          editor = "nvim";
          autoclrf = "true";
        };
        color = { ui = "auto"; };
        init = { defaultBranch = "main"; };
        web = { browser = "firefox"; };
        github = { user = "joshua1571"; };
      };
      ignores = [
        "*.bak"
        "*.gho"
        "*.ori"
        "*.orig"
        "*.tmp"
        "*.retry"
        ".ansible/"
        # Dropbox settings and caches
        ".dropbox"
        ".dropbox.attr"
        ".dropbox.cache"
        # JPEG
        "*.jpg"
        "*.jpeg"
        "*.jpe"
        "*.jif"
        "*.jfif"
        "*.jfi"

        # JPEG 2000
        "*.jp2"
        "*.j2k"
        "*.jpf"
        "*.jpx"
        "*.jpm"
        "*.mj2"

        # JPEG XR
        "*.jxr"
        "*.hdp"
        "*.wdp"

        # Graphics Interchange Format
        "*.gif"

        # RAW
        "*.raw"

        # Web P
        "*.webp"

        # Portable Network Graphics
        "*.png"

        # Animated Portable Network Graphics
        "*.apng"

        # Multiple-image Network Graphics
        "*.mng"

        # Tagged Image File Format
        "*.tiff"
        "*.tif"

        # Scalable Vector Graphics
        "*.svg"
        "*.svgz"

        # Portable Document Format
        "*.pdf"

        # X BitMap
        "*.xbm"

        # BMP
        "*.bmp"
        "*.dib"

        # ICO
        "*.ico"

        # 3D Images
        "*.3dm"
        "*.max"

        # Swap Files #
        ".*.kate-swp"
        ".swp.*"

        #GPG Keys
        "secring.*"

        # temporary files which can be created if a process still has a handle open of a deleted file
        ".fuse_hidden*"

        # Metadata left by Dolphin file manager, which comes with KDE Plasma
        ".directory"

        # Linux trash folder which might appear on any partition or disk
        ".Trash-*"

        # .nfs files are created when an open file is removed but is still being accessed
        ".nfs*"

        # Log files created by default by the nohup command
        "nohup.out"

        # Syncthing caches
        ".stversions"

        # Swap
        "[._]*.s[a-v][a-z]"
        # comment out the next line if you don't need vector files
        #!*.svg
        #[._]*.sw[a-p]"
        #[._]s[a-rt-v][a-z]"
        #[._]ss[a-gi-z]"
        #[._]sw[a-p]"

        # Session
        "Session.vim"
        "Sessionx.vim"

        # Temporary
        ".netrwhist"
        "*~"
        # Auto-generated tag files
        "tags"
        # Persistent undo
        "[._]*.un~"

        # Virtualenv
        # https://realpython.com/python-virtual-environments-a-primer/#the-virtualenv-project
        ".Python"
        "[Bb]in"
        "[Ii]nclude"
        "[Ll]ib"
        "[Ll]ib64"
        "[Ll]ocal"
        "[Ss]cripts"
        "pyvenv.cfg"
        ".venv"
        "pip-selfcheck.json"

        ".vscode/*"
        "!.vscode/settings.json"
        "!.vscode/tasks.json"
        "!.vscode/launch.json"
        "!.vscode/extensions.json"
        "!.vscode/*.code-snippets"
        "!*.code-workspace"

        # Built Visual Studio Code Extensions
        "*.vsix"

        # Windows thumbnail cache files
        "Thumbs.db"
        "Thumbs.db:encryptable"
        "ehthumbs.db"
        "ehthumbs_vista.db"

        # Dump file
        "*.stackdump"

        # Folder config file
        "[Dd]esktop.ini"

        # Recycle Bin used on file shares
        "$RECYCLE.BIN/"

        # Windows Installer files
        "*.cab"
        "*.msi"
        "*.msix"
        "*.msm"
        "*.msp"

        # Windows shortcuts
        "*.lnk"

        # General
        ".DS_Store"
        "__MACOSX/"
        ".AppleDouble"
        ".LSOverride"
        "Icon[]"

        # Thumbnails
        "._*"

        # Files that might appear in the root of a volume
        ".DocumentRevisions-V100"
        ".fseventsd"
        ".Spotlight-V100"
        ".TemporaryItems"
        ".Trashes"
        ".VolumeIcon.icns"
        ".com.apple.timemachine.donotpresent"

        # Directories potentially created on remote AFP share
        ".AppleDB"
        ".AppleDesktop"
        "Network Trash Folder"
        "Temporary Items"
        ".apdisk"

        # Autosave files
        "*.asv"
        "*.m~"
        "*.autosave"
        "*.slx.r*"
        "*.mdl.r*"

        # Derived content-obscured files
        "*.p"

        # Compiled MEX files
        "*.mex*"

        # Packaged app and toolbox files
        "*.mlappinstall"
        "*.mltbx"

        # Deployable archives
        "*.ctf"

        # Generated helpsearch folders
        "helpsearch*/"

        # Code generation folders
        "slprj/"
        "sccprj/"
        "codegen/"

        # Cache files
        "*.slxc"

        # Cloud based storage dotfile
        ".MATLABDriveTag"

        # Covers JetBrains IDEs: IntelliJ, GoLand, RubyMine, PhpStorm, AppCode, PyCharm, CLion, Android Studio, WebStorm and Rider
        # Reference: https://intellij-support.jetbrains.com/hc/en-us/articles/206544839

        # User-specific stuff
        ".idea/**/workspace.xml"
        ".idea/**/tasks.xml"
        ".idea/**/usage.statistics.xml"
        ".idea/**/dictionaries"
        ".idea/**/shelf"

        # AWS User-specific
        ".idea/**/aws.xml"

        # Generated files
        ".idea/**/contentModel.xml"

        # Sensitive or high-churn files
        ".idea/**/dataSources/"
        ".idea/**/dataSources.ids"
        ".idea/**/dataSources.local.xml"
        ".idea/**/sqlDataSources.xml"
        ".idea/**/dynamic.xml"
        ".idea/**/uiDesigner.xml"
        ".idea/**/dbnavigator.xml"

        # Gradle
        ".idea/**/gradle.xml"
        ".idea/**/libraries"

        # Gradle and Maven with auto-import
        # When using Gradle or Maven with auto-import, you should exclude module files,
        # since they will be recreated, and may cause churn.  Uncomment if using
        # auto-import.
        # .idea/artifacts
        # .idea/compiler.xml
        # .idea/jarRepositories.xml
        # .idea/modules.xml
        # .idea/*.iml
        # .idea/modules
        # *.iml
        # *.ipr

        # CMake
        "cmake-build-*/"

        # Mongo Explorer plugin
        ".idea/**/mongoSettings.xml"

        # File-based project format
        "*.iws"

        # IntelliJ
        "out/"

        # mpeltonen/sbt-idea plugin
        ".idea_modules/"

        # JIRA plugin
        "atlassian-ide-plugin.xml"

        # Cursive Clojure plugin
        ".idea/replstate.xml"

        # SonarLint plugin
        ".idea/sonarlint/"
        ".idea/sonarlint.xml" # see https://community.sonarsource.com/t/is-the-file-idea-idea-idea-sonarlint-xml-intended-to-be-under-source-control/121119

        # Crashlytics plugin (for Android Studio and IntelliJ)
        "com_crashlytics_export_strings.xml"
        "crashlytics.properties"
        "crashlytics-build.properties"
        "fabric.properties"

        # Editor-based HTTP Client
        ".idea/httpRequests"
        "http-client.private.env.json"

        # Android studio 3.1+ serialized cache file
        ".idea/caches/build_file_checksums.ser"

        # Apifox Helper cache
        ".idea/.cache/.Apifox_Helper"
        ".idea/ApifoxUploaderProjectSetting.xml"
      ];
    };

    bash = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        ll = "eza -l -o -g";
        lla = "eza -l -o -g -a";
        grep = "rg --color=auto";
        gits = "git status";
        gitd = "git diff";
        tput = "trash-put";
        tlist = "trash-list";
        trestore = "trash-restore";
      };
    };

    bat.enable = true;

    firefox.enable = true;

    aerc.enable = true;

    zathura.enable = true;

    fzf.enable = true;

    fd.enable = true;

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    eza = {
      enable = true;
      colors = "auto";
      git = true;
      icons = "auto";
    };

    ripgrep.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;

    };

    ncspot.enable = true;

    mpv.enable = true;

    aria2 = {
      enable = true;
      settings = { dir = "/home/jrh/Downloads"; };
    };

    yazi = {
      enable = true;
      settings = {
        log = { enabled = false; };
        mgr = {
          show_hidden = false;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
          show_symlink = true;
        };
      };
    };

    wezterm = {
      enable = true;
      extraConfig = ''
        -- This will hold the configuration.
        local config = wezterm.config_builder()
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
    };

    tmux = {
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

    # TODO: Replace with nixvim
    neovim = {
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

  };

  # Services
  services = {
    dropbox.enable = true;
    opensnitch-ui.enable = true;
    gpg-agent.enable = true;
  };

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
