local km = require("config.keymap-helper")

vim.o.timeoutlen = 300
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Buffers
km.register("n", "<C-Tab>", "<cmd>BufferNext<CR>", "next buffer (screen order)")
km.register("n", "<C-S-Tab>", "<cmd>BufferPrevious<CR>", "prev buffer (screen order)")
km.register("n", "<Tab>", "<cmd>BufferNext<CR>", "next buffer")
km.register("n", "<S-Tab>", "<cmd>BufferPrevious<CR>", "prev buffer")
km.register("n", "<S-l>", "<cmd>BufferNext<CR>", "next buffer")
km.register("n", "<S-h>", "<cmd>BufferPrevious<CR>", "prev buffer")

-- Windows
km.register("n", "<C-h>", "<C-w>h", "window left")
km.register("n", "<C-j>", "<C-w>j", "window down")
km.register("n", "<C-k>", "<C-w>k", "window up")
km.register("n", "<C-l>", "<C-w>l", "window right")

-- Search & File creation
km.register("n", "<leader>f", ":lua require('utils.git-root-search').open_files()<CR>", "files (git root)")
km.register("n", "<leader>F", ":lua require('utils.git-root-search').open_grep()<CR>", "grep (git root)")
km.register("n", "<leader>cf", ":CreateFile<CR>", "create file in dir")

-- File explorer
km.register("n", "<leader>e", ":Neotree filesystem toggle left<CR>", "toggle tree")
km.register("n", "<C-n>", ":Neotree filesystem toggle left<CR>", "toggle tree")

-- Git
km.register("n", "<leader>gs", function() require("neogit").open({ kind = "tab" }) end, "status")

-- Theme picker
km.register("n", "<leader>t", "<cmd>Theme<CR>", "select theme")

-- Terminal
km.register("n", "<leader>z", ":lua require('FTerm').open()<CR>", "floating terminal")
km.register("t", "<Esc>", "<C-\\><C-n><CMD>lua require('FTerm').close()<CR>", "close terminal")

-- Plugins
km.register("n", "<leader>P", ":Lazy sync<CR>", "plugins sync")

-- File editing & commenting keymaps (scoped to editable file buffers)
require("config.mappings.comment").setup()

-- Language-specific buffer keymaps
require("config.mappings.cpp")
require("config.mappings.lsp")
require("config.mappings.dap")
require("config.mappings.python")
