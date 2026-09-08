-- bread's neovim config (with cacharle's C/C++ enhancements)
-- keymaps are in lua/config/mappings.lua
-- install a patched font & ensure your terminal supports glyphs
-- enjoy :D

vim.g.start_time = vim.fn.reltime()
vim.loader.enable() --  SPEEEEEEEEEEED 

-- This prevents Vim from creating a netrw buffer for directory arguments
-- Netrw is replaced by Neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Plugin manager backend: lazy.nvim
require("core.lazy")

-- move config and plugin config to alternate files
require("config.theme")
require("config.health-compat")
require("config.keymap-helper") -- helper for vim.keymap + which-key registration
require("config.mappings")
require("config.options")
require("config.autocmd")
require("config.lint-toggle")

-- lazy.nvim specs now own plugin setup; keep runtime-only modules here.
-- bufdelete: smart buffer deletion
pcall(require, "bufdelete")

-- Lazy load LSP per language (cacharle's approach)
-- Setup on first FileType event, then start LSP immediately
-- Centralized LSP configuration hub
require("lsp").setup()

load_theme()
