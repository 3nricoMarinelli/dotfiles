-- neovim keybindings
-- organized by: vanilla neovim → plugins
-- all mappings auto-register with which-key via keymap-helper

local km = require("config.keymap-helper")

vim.o.timeoutlen = 300 -- wait 300ms for next key in sequence
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Vanilla Neovim: Remove built-in keybindings
-- unmap 0.10+ commenting (we use <leader>/ and <leader>?)
vim.keymap.del("n", "gc")
vim.keymap.del("n", "gcc")
vim.keymap.del("x", "gc")
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Vanilla Neovim: Buffers
km.register("n", "<S-l>", ":bnext<CR>", "next buffer")
km.register("n", "<S-h>", ":bprevious<CR>", "prev buffer")
km.register("n", "<leader>x", ":bd<CR>", "quit buffer")

-- Vanilla Neovim: Windows
km.register("n", "<C-h>", "<C-w>h", "window left")
km.register("n", "<C-j>", "<C-w>j", "window down")
km.register("n", "<C-k>", "<C-w>k", "window up")
km.register("n", "<C-l>", "<C-w>l", "window right")

-- Vanilla Neovim: Line Numbers
km.register("n", "<leader>n", function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end, "toggle relative nums")

-- Vanilla Neovim: Search & Replace Everywhere Word under cursor
km.register("n", "<leader>R", ":%s/<C-r><C-w>/<C-r><C-w>/g<Left><Left>", "search and replace")

-- Vanilla Neovim: Replace Word
km.register("n", "<leader>r", "ve\"_dP", "replace")

-- Vanilla Neovim: Text Formatting
km.register("n", "<leader>W", ":set wrap!<CR>", "toggle wrap")

-- Plugins: Telescope (git-root aware with Tab toggle)
-- <leader>f - Files in git root (or cwd), Tab toggles to grep
-- <leader>s - Grep in git root (or cwd), Tab toggles to files
-- Git root detection: finds first .git in parent dirs, falls back to cwd
km.register(
  "n",
  "<leader>f",
  ":lua require('utils.git-root-search').open_files()<CR>",
  "files (git root)"
)
km.register(
  "n",
  "<leader>F",
  ":lua require('utils.git-root-search').open_grep()<CR>",
  "grep (git root)"
)

-- Plugins: Comment.nvim & Documentation (managed in lua/config/mappings/comment.lua)
require("config.mappings.comment")

-- Plugins: Neogit (git interface)
km.register("n", "<leader>gs", function()
  require("neogit").open({ kind = "tab" })
end, "status")

-- Plugins: Gitsigns (git signs + hunks)
km.register("n", "<leader>ga", function()
  require("gitsigns").stage_hunk()
end, "stage")
km.register("n", "<leader>gu", function()
  require("gitsigns").undo_stage_hunk()
end, "unstage")
km.register("n", "<leader>gv", function()
  require("gitsigns").preview_hunk()
end, "preview")
km.register("n", "<leader>gb", function()
  require("gitsigns").blame_line({ full = true })
end, "blame")
km.register("n", "<leader>gj", function()
  require("gitsigns").next_hunk()
end, "next")
km.register("n", "<leader>gk", function()
  require("gitsigns").prev_hunk()
end, "prev")
km.register("n", "<leader>gr", function()
  require("gitsigns").reset_hunk()
end, "reset")

-- Plugins: Neo-tree (file explorer)
km.register(
  "n",
  "<leader>t",
  ":Neotree filesystem toggle left<CR>",
  "toggle tree"
)

-- Plugins: FTerm (floating terminal)
km.register("n", "<leader>z", ":lua require('FTerm').open()<CR>", "floating terminal")
km.register("t", "<Esc>", "<C-\\><C-n><CMD>lua require('FTerm').close()<CR>", "close terminal")

-- Plugins: lazy.nvim
km.register("n", "<leader>P", ":Lazy sync<CR>", "plugins sync")

-- Domain-specific keymaps (modularized in lua/config/mappings/)
require("config.mappings.cpp")
require("config.mappings.lsp")
require("config.mappings.dap")
require("config.mappings.python")
