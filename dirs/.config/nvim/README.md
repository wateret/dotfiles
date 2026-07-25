# nvim config

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (`vim.pack`-based, requires Neovim 0.12+).

Custom additions on top of stock kickstart:

- `pyright`, `ts_ls`, `bashls` LSP servers (in addition to `lua_ls`, `clangd`)
- HANA-aware `clangd` setup: auto-detects a `.hmproject` repo and points clangd at the
  SAP-patched binary + matching build profile via `hm tool --print-path clangd`
- `nvim-osc52` for clipboard yank over SSH (`<leader>y` / `<leader>yy`)
