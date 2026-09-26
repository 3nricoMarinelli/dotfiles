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

-- Ensure Homebrew binaries are accessible on macOS
if vim.fn.has("mac") == 1 then
  if not vim.env.PATH:find("/opt/homebrew/bin", 1, true) then
    vim.env.PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:" .. vim.env.PATH
  end
end
-- Compatibility shims for older plugin APIs (must load before plugins)
require("config.health-compat")

-- Plugin manager backend: lazy.nvim
require("core.lazy")

-- move config and plugin config to alternate files
require("config.theme")

require("config.keymap-helper") -- helper for vim.keymap + which-key registration
require("config.mappings")
require("config.options")
require("config.autocmd")
require("config.lint-toggle")

-- lazy.nvim specs now own plugin setup; keep runtime-only modules here.
-- bufdelete: smart buffer deletion
pcall(require, "bufdelete")

-- Centralized LSP configuration hub
require("lsp").setup()
require("lsp.hooks").setup()

-- C/C++ development tools (skeleton, trivial constructor, extract, include formatter/rename)
require("tools").setup()

require("config.theme").setup()
