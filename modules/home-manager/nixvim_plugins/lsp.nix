# All LSP related configs
{ pkgs, ... }: {
  home.packages = with pkgs; [
    pyright
    nil
    docker-language-server
    bash-language-server
    marksman
    yaml-language-server
  ];

  programs.nixvim = {
    diagnostic.settings.virtual_text = true;

    lsp = {
      inlayHints.enable = true;
      servers = {
        nil_ls.enable = true; # Nix
        dockerls.enable = true; # Docker
        bashls.enable = true; # Bash
        pyright.enable = true; # Python
        marksman.enable = true; # Markdown
        yamlls.enable = true; # YAML
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
