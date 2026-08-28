# Nixvim

Neovim is configured via [nixvim](https://github.com/nix-community/nixvim),
pinned to `nixos-25.11` and following the flake's `nixpkgs`.

## File layout

Everything lives under `modules/home-manager/`:

| File | Purpose |
|---|---|
| `nixvim.nix` | Top-level entry: options, colorscheme, plugins |
| `nixvim_keymaps.nix` | All keybindings (leader = `<Space>`) |
| `nixvim_completions.nix` | Completion sources |
| `nixvim_plugins/` | One file per plugin |

## Keymap conventions

- Leader is `<Space>`.
- `:command`-style actions **must** end with `<CR>` — nixvim renders the
  string as literal keystrokes and won't execute the command otherwise.
- Raw key sequences (e.g. `<C-w>h`) and plugin action names (e.g. fzf-lua's
  `<cmd>FzfLua files<cr>`) do **not** need a trailing `<CR>`.

