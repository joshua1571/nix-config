{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      nixvimInjections = true;

      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      #folding.enable = false;
    };

    treesitter-context.enable = true;

    # hmts.nvim is unmaintained and breaks with newer Neovim treesitter APIs
    # (languagetree parse -> "attempt to call method 'parent' (a nil value)").
    hmts.enable = false;
  };
}
