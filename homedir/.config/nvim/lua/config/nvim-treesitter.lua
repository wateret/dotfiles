require('nvim-treesitter')
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "python", "sql", "json", "xml", "csv", "markdown" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
})
