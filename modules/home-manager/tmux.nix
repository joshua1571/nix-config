{ pkgs, ... }: {
  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      extraConfig = ''
        # bell
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R

        set -g bell-action any
        set -g visual-bell on
        set -g visual-activity on

        set -g set-titles on
        set -g renumber-windows on

        set -g status on
        set -g status-interval 30 #Update status every 30 seconds

        setw -g automatic-rename on
        setw -g monitor-activity on

        #  modes
        setw -g clock-mode-colour colour232
        setw -g clock-mode-style 12

        # panes
        set -g pane-border-style bg=default,fg=colour234
        set -g pane-active-border-style bg=default,fg=colour237

        # statusbar
        set -g status-position bottom
        set -g status-justify left
        set -g status-style bg=default,fg=colour137,dim
        set -g status-left ""
        set -g status-right "#[fg=colour231,bg=default,bold] %m/%d #[fg=colour255,bg=default,bold] %H:%M "
        #set -g status-right-length 50
        #set -g status-left-length 20

        setw -g window-status-current-style fg=colour1,bg=default,bold
        setw -g window-status-current-format " #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F"

        setw -g window-status-style fg=colour9,bg=default,none
        setw -g window-status-format " #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F"

        setw -g window-status-bell-style bg=default,fg=colour255,bold

        # messages
        set -g message-style bg=default,fg=colour1,bold
      '';
    };
  };
}
