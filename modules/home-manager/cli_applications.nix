{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Command Line Applications
    gh
    trash-cli
    nmap
    ddgr
    cheat
    rclone
  ];

  programs = {
    ncspot.enable = true;
    bat.enable = true;
    aerc.enable = true;
    fzf.enable = true;
    fd.enable = true;
    ripgrep.enable = true;

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

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;

    };

    aria2 = {
      enable = true;
      settings = {
        dir = "/home/jrh/Downloads";
      };
    };

    yazi = {
      enable = true;
      settings = {
        log = {
          enabled = false;
        };
        mgr = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
          sort_reverse = false;
          show_symlink = true;
        };
        preview = {
          image_delay = 100;
        };
      };
    };
  };
}
