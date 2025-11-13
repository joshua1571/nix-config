{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        action = "<NOP>";
        key = "<Space>";
      }
      {
        # Esc to clear search results
        action = ":noh<CR>";
        key = "<esc>";
      }
      {
        # navigate to left window
        action = "<C-w>h";
        key = "<leader>h";
      }
      {
        # navigate to right window
        action = "<C-w>l";
        key = "<leader>l";
      }
    ];
  };
}
