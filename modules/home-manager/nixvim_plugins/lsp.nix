# All LSP related configs
{
  programs.nixvim = {
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

    plugins = {
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };

      # Sane defaults for all servers
      lspconfig.enable = true;
    };
  };
}
