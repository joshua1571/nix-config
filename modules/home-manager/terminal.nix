{ pkgs, ... }: {
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
  };
}
