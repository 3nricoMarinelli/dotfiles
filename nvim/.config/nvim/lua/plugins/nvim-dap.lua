-- DAP (Debug Adapter Protocol) Setup
-- Centralizes nvim-dap initialization: UI, virtual text, and adapters
-- Keybindings are applied per-buffer by language-specific LSP files
--
-- Keybindings (set by dap/keymaps.lua, applied per language):
--   <leader>Db  - Toggle breakpoint
--   <leader>Dc  - Continue / Start
--   <leader>Do  - Step over
--   <leader>Di  - Step into
--   <leader>DO  - Step out
--   <leader>Dq  - Terminate session
--   <leader>Du  - Toggle DAP UI

local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
  return
end

-- Setup DAP breakpoints and deferred initialization
require("dap.init").setup()
