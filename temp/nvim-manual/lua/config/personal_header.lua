-- Settings before plugins loaded

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.o.winbar = "%t %m"
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Buffers
vim.opt.hidden = true
vim.opt.autoread = true

-- Editing
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Clipboard
-- vim.opt.clipboard = "unnamedplus"

-- Performance
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400

-- Keymaps
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", ":Neotree left reveal<CR>", { silent = true })
vim.keymap.set("n", "<leader>E", ":Neotree close<CR>", { silent = true })
vim.keymap.set("n", "<leader>w", function()
  vim.cmd("wincmd w")
end, { silent = true })
vim.keymap.set("n", "<leader>f", ":FzfLua files<CR>", { silent = true })
