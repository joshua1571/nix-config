{ nixvim, ... }:
{
  imports = [
    nixvim.homeModules.nixvim

    ./nixvim_plugins/gitsigns.nix
    ./nixvim_plugins/lsp.nix
    ./nixvim_plugins/lualine.nix
    ./nixvim_plugins/treesitter.nix
    ./nixvim_plugins/neo-tree.nix
    # TODO: Add keymaps for telescope ./nixvim_plugins/telescope.nix
    ./nixvim_keymaps.nix
    ./nixvim_completions.nix

    # Ideas from: https://github.com/Ahwxorg/nixvim-config/blob/master/config/plugins.nix
    # TODO: debugger https://github.com/mfussenegger/nvim-dap
  ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    defaultEditor = true;

    colorschemes.gruvbox.enable = true;
    highlightOverride = {
      Normal.bg = "NONE";
      NonText.bg = "NONE";
      NormalFloat.bg = "NONE";
      Signcolumn.bg = "NONE";
    };

    opts = {
      updatetime = 100; # Faster completion
      splitbelow = true;
      splitright = true;
      number = true;
      relativenumber = true;
      cursorline = true;
      cursorcolumn = true;
      signcolumn = "yes";
      #colorcolumn = "100";
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = false;
      smartindent = false;
      autoindent = true;
      wrap = false;
      mouse = "a";
      termguicolors = true;
      swapfile = false;
      modeline = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      scrolloff = 3;
      fileencoding = "utf-8";
    };

    dependencies = {
      gcc.enable = false;
    };

    # https://mattsturgeon.github.io/nixvim/plugins/actions-preview/index.html
    plugins = {
      lz-n.enable = true; # Lazy loading
      which-key.enable = true;
      nvim-autopairs.enable = true;
      web-devicons.enable = true;

      cmp = {
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
          };
        };
      };

      illuminate = {
        enable = true;
        settings = {
          under_cursor = false;
          filetypes_denylist = [ "TelescopePrompt" ];
        };
      };

      hardtime = {
        enable = true;
        settings = {
          disableMouse = true;
          enabled = true;
          #disabledFiletypes = [ "Oil" ];
          restrictionMode = "hint";
          hint = true;
          maxCount = 40;
          maxTime = 1000;
          restrictedKeys = {
            #"h" = [
            #  "n"
            #  "x"
            #];
            "j" = [
              "n"
              "x"
            ];
            "k" = [
              "n"
              "x"
            ];
            #"l" = [
            #  "n"
            #  "x"
            #];
          };
        };
      };
    };

  };
}
