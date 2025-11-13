{ pkgs, nixvim, ... }: {
  imports = [ nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    defaultEditor = true;

    # Remap leader key
    # TODO: Leader key not working
    globals = {
      mapleader = ",";
      maplocalleader = ",";
    };

    diagnostic.settings.virtual_text = true;
    lsp = {
      inlayHints.enable = true;
      servers = {
        lua_ls = {
          enable = true;
          config.settings.diagnostics.globals = [ "vim" ];
        };
      };
    };

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      cursorcolumn = true;
      signcolumn = "yes";
      colorcolumn = "100";
      tabstop = 4;
      shiftwidth = 4;
      expandtab = false;
      smartindent = false;
      wrap = false;
      mouse = "a";
      termguicolors = true;
      swapfile = false;
      modeline = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      scrolloff = 5;
    };

    # https://mattsturgeon.github.io/nixvim/plugins/actions-preview/index.html
    # TODO: Configure plugins
    plugins = {
	  # Lazy loading
      lz-n.enable = true;
      cmp = {
        autoEnableSources = true;
        settings.sources =
          [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
      };

      web-devicons.enable = true;

      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      nvim-autopairs.enable = true;

      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };

      # Sane defaults for all servers
      lspconfig.enable = true;

      lualine = {
        enable = true;

        settings = {
          options.globalstatus = true;

          # +-------------------------------------------------+
          # | A | B | C                             X | Y | Z |
          # +-------------------------------------------------+
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" ];
            lualine_c = [ "filename" "diff" ];

            lualine_x = [
              "diagnostics"

              # Show active language server
              {
                __unkeyed.__raw = ''
                  function()
                      local msg = ""
                      local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                      local clients = vim.lsp.get_clients()
                      if next(clients) == nil then
                          return msg
                      end
                      for _, client in ipairs(clients) do
                          local filetypes = client.config.filetypes
                          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                              return client.name
                          end
                      end
                      return msg
                  end
                '';
                icon = "";
                color.fg = "#ffffff";
              }
              "encoding"
              "fileformat"
              "filetype"
            ];
          };
        };
      };

      telescope.enable = true;
      treesitter.enable = true;
      which-key.enable = true;

    };

    colorschemes.gruvbox.enable = true;
  };
}
