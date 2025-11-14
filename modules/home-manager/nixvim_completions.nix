{
  programs.nixvim.plugins = {
    cmp-nvim-lsp = {
      enable = true; # LSP
    };
    cmp-buffer = { enable = true; };
    cmp-path = {
      enable = true; # file system paths
    };
    cmp_luasnip = {
      enable = true; # snippets
    };
    cmp-cmdline = {
      enable = true; # autocomplete for cmdline
    };
    cmp = {
      enable = true;
      settings = {
        completion = { completeopt = "menu,menuone,noinsert"; };
        autoEnableSources = true;
        experimental = { ghost_text = true; };
        performance = {
          debounce = 60;
          fetchingTimeout = 200;
          maxViewEntries = 30;
        };
        #snippet = { 
        #  expand = ''
        #    function(args)
        #      require('luasnip').lsp_expand(args.body)
        #    end
        #  '';
        #};
        formatting = { fields = [ "kind" "abbr" "menu" ]; };
        sources = [
          {
            name = "nvim_lsp";
          }
          #{ name = "emoji"; }
          {
            name = "buffer"; # text within current buffer
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            keywordLength = 3;
          }
          # { name = "copilot"; } # enable/disable copilot
          {
            name = "path"; # file system paths
            keywordLength = 3;
          }
          #{
          #  name = "luasnip"; # snippets
          #  keywordLength = 3;
          #}
        ];
      };
    };
  };
}
