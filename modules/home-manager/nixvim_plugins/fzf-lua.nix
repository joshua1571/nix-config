{
  programs.nixvim.plugins = {
    fzf-lua = {
      enable = true;
      profile = "fzf-native";
      # https://github.com/AntonioDrumond/nixvim/blob/2d41633710c3527cd34026ab3f10e8eafe671d83/config/plug/ui/fzf-lua.nix#L4
      keymaps = {
        "<leader>fg" = "live_grep";
        #"<C-p>" = {
        #  action = "git_files";
        #  settings = {
        #    previewers.cat.cmd = lib.getExe' pkgs.coreutils "bat";
        #    winopts.height = 0.5;
        #  };
        #  options = {
        #    silent = true;
        #    desc = "Fzf-Lua Git Files";
        #  };
        "<leader>lg" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>b" = {
          action = "buffers";
          options.desc = "Buffers";
        };
        "<leader>gc" = {
          action = "git_commits";
          options.desc = "git commits";
        };
        "<leader>gs" = {
          action = "git_status";
          options.desc = "git status";
        };
        "<leader>r" = {
          action = "registers";
          options.desc = "registers";
        };
        "<leader>sd" = {
          action = "diagnostics_document";
          options.desc = "diagnostics document";
        };
        "<leader>sD" = {
          action = "diagnostics_workspace";
          options.desc = "diagnostics workspace";
        };
        "<leader>sh" = {
          action = "help_tags";
          options.desc = "help tags";
        };
        "<leader>sk" = {
          action = "keymaps";
          options.desc = "keymaps";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "buffers";
        };
        "<leader>ff" = {
          action = "files";
          options.desc = "find files";
        };
        "<leader>fw" = {
          action = "grep_cword";
          options.desc = "grep cword";
        };
        "<leader>fW" = {
          action = "grep_cWORD";
          options.desc = "grep cWORD";
        };
      };
      settings = {
        files = {
          color_icons = true;
          file_icons = true;
          #find_opts = {
          #  __raw = "[[-type f -not -path '*.git/objects*' -not -path '*.env*']]";
          #};
          multiprocess = true;
          prompt = "Files❯ ";
        };
        winopts = {
          col = 0.3;
          height = 0.4;
          row = 0.99;
          width = 0.93;
        };
      };
    };
  };
}
