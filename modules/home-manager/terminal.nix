{ ... }:
{
  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
        -- This will hold the configuration.
        local config = wezterm.config_builder()
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
          preferred = "RESIZE";
          size = "0";
          color = "00000000";
        };
        colors = {
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
