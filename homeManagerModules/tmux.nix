{ pkgs, ... }: {
  programs = {
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
  };
}
