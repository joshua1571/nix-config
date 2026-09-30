_: {
  #home.packages = [ pkgs.ghostty ];

  programs = {
    ghostty = {
      enable = true;
      systemd.enable = true;
      enableBashIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
      settings = {
        font-size = 10;
        keybind = [
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"

          ## create splits
          "ctrl+shift+5=new_split:right"
          "ctrl+shift+semicolon=new_split:down"

          ## navigate with vim keys (ctrl+shift+k removed to avoid conflict with clear_screen)
          "ctrl+shift+h=goto_split:left"
          "ctrl+shift+j=goto_split:bottom"
          "ctrl+shift+l=goto_split:right"
          ## Note: Use Alt+Up for top split navigation instead

          ## or arrow keys
          "alt+left=goto_split:left"
          "alt+right=goto_split:right"
          "alt+up=goto_split:top"
          "alt+down=goto_split:bottom"

          ## split management
          "ctrl+shift+z=toggle_split_zoom" # maximize current split
          "ctrl+shift+equal=equalize_splits" # balance split sizes

          ## quick terminal
          "ctrl+backquote=toggle_quick_terminal"

          ## tab creation/navigation
          "ctrl+shift+t=new_tab"
          "ctrl+tab=next_tab"
          "ctrl+shift+tab=previous_tab"

          ## Note: Ctrl+1-9 bindings removed to preserve standard terminal behavior
          ## Use Ctrl+Tab/Ctrl+Shift+Tab for tab navigation instead

          ## tab movement
          #"ctrl+shift+alt+left=move_tab:-1"
          #"ctrl+shift+alt+right=move_tab:1"

        ];
        theme = "Gruvbox Dark";
        background-opacity = 0.8;
        background-blur = 0;
        gtk-single-instance = "desktop";
        scrollback-limit = 100000000;
        scrollbar = "never";
        shell-integration = "detect";
        shell-integration-features = "cursor, sudo, title";
        quick-terminal-position = "top";
        quick-terminal-screen = "main";
        quick-terminal-animation-duration = 0.2;
        quick-terminal-autohide = true;
        clipboard-read = "ask"; # prompts before programs read clipboard
        clipboard-write = "allow"; # allows writing to clipboard
        clipboard-paste-protection = true; # warns about dangerous pastes (e.g., commands with newlines)
        copy-on-select = true; # auto-copy selection
        title-report = false;

      };
    };

    wezterm = {
      enable = true;
      extraConfig = ''
                -- This will hold the configuration.
        				local wezterm = require 'wezterm'
                local config = wezterm.config_builder()
        				local act = wezterm.action
                -- Fonts and Colors
                config.font_size = 10
                config.font = wezterm.font 'FiraCode Nerd Font Mono'
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
        				-- Mouse
        				config.mouse_bindings = {
                  {
                    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
                    mods = 'NONE',
                    action = act.ScrollByLine(-1),
                  },
                  {
                    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
                    mods = 'NONE',
                    action = act.ScrollByLine(1),
                  },
                }
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

    foot = {
      enable = true;
      settings = {
        main = {
          font = "SauceCodePro Nerd Font:size=10";
        };
        cursor = {
          style = "Block";
          blink = "yes";
          blink-rate = 500;
        };
        mouse = {
          hide-when-typing = "yes";
        };
        csd = {
          preferred = "server";
          size = "12";
          color = "00282828";
          hide-when-maximized = "yes";
        };
        colors-dark = {
          alpha = "0.8";
          #background = "282828";
          background = "000000";
          foreground = "ebdbb2";
          regular0 = "282828";
          regular1 = "cc241d";
          regular2 = "98971a";
          regular3 = "d79921";
          regular4 = "458588";
          regular5 = "b16286";
          regular6 = "689d6a";
          regular7 = "a89984";
          bright0 = "928374";
          bright1 = "fb4934";
          bright2 = "b8bb26";
          bright3 = "fabd2f";
          bright4 = "83a598";
          bright5 = "d3869b";
          bright6 = "8ec07c";
          bright7 = "ebdbb2";
        };
      };
    };
  };
}
