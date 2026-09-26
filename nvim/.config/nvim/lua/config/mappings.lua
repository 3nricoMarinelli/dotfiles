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
km.register("n", "<leader>x", "<cmd>BufferClose<CR>", "close buffer")

-- Windows
km.register("n", "<C-h>", "<C-w>h", "window left")
km.register("n", "<C-j>", "<C-w>j", "window down")
km.register("n", "<C-k>", "<C-w>k", "window up")
km.register("n", "<C-l>", "<C-w>l", "window right")

-- Line Numbers
km.register("n", "<leader>n", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
  vim.wo.number = true
end, "toggle relative nums")

-- Text Editing
km.register("n", "<leader>R", ":%s/<C-r><C-w>/<C-r><C-w>/g<Left><Left>", "search and replace")
km.register("n", "<leader>r", "ve\"_dP", "replace")
km.register("n", "<leader>W", ":set wrap!<CR>", "toggle wrap")

-- Search & File creation
km.register("n", "<leader>f", ":lua require('utils.git-root-search').open_files()<CR>", "files (git root)")
km.register("n", "<leader>F", ":lua require('utils.git-root-search').open_grep()<CR>", "grep (git root)")
km.register("n", "<leader>cf", ":CreateFile<CR>", "create file in dir")

require("config.mappings.comment")

-- Git
km.register("n", "<leader>gs", function() require("neogit").open({ kind = "tab" }) end, "status")
km.register("n", "<leader>ga", function() require("gitsigns").stage_hunk() end, "stage")
km.register("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, "unstage")
km.register("n", "<leader>gv", function() require("gitsigns").preview_hunk() end, "preview")
km.register("n", "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, "blame")
km.register("n", "<leader>gj", function() require("gitsigns").next_hunk() end, "next")
km.register("n", "<leader>gk", function() require("gitsigns").prev_hunk() end, "prev")
km.register("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, "reset")

-- File explorer
km.register("n", "<leader>e", ":Neotree filesystem toggle left<CR>", "toggle tree")
km.register("n", "<C-n>", ":Neotree filesystem toggle left<CR>", "toggle tree")

-- Theme picker
km.register("n", "<leader>ts", "<cmd>Theme<CR>", "select theme")
km.register("n", "<leader>tn", "<cmd>ThemeNext<CR>", "next theme")
km.register("n", "<leader>tp", "<cmd>ThemePrev<CR>", "prev theme")

-- Terminal
km.register("n", "<leader>z", ":lua require('FTerm').open()<CR>", "floating terminal")
km.register("t", "<Esc>", "<C-\\><C-n><CMD>lua require('FTerm').close()<CR>", "close terminal")

-- Plugins
km.register("n", "<leader>P", ":Lazy sync<CR>", "plugins sync")

require("config.mappings.cpp")
require("config.mappings.lsp")
require("config.mappings.dap")
require("config.mappings.python")
