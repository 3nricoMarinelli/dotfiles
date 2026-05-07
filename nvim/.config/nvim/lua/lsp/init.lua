-- LSP Configuration Hub
-- Centralizes all LSP setup, keymaps, hints, tokens, and common handlers
-- Language-specific configs: c-cpp, python, rust, typst

local M = {}

-- Import sub-modules
local common = require("lsp.common")
local keymaps = require("lsp.keymaps")
local hints = require("lsp.hints")
local tokens = require("lsp.tokens")

function M.on_attach(client, bufnr)
  -- Apply keymaps
  keymaps.apply(bufnr)

  -- Setup inlay hints
  hints.enable(bufnr)

  -- Setup semantic tokens
  tokens.on_attach(client, bufnr)
end

--- Get LSP capabilities (used by language-specific configs)
function M.capabilities()
  return common.capabilities()
end

--- Setup global LSP configuration
function M.setup()
  -- Setup LSP handlers (split view, etc.)
  common.setup_handlers()

  -- Setup inlay hints
  hints.setup()

  -- Setup semantic tokens highlights
  tokens.setup()

  -- Setup diagnostics display
  vim.diagnostic.config({
    virtual_text = {
      prefix = "● ",
      severity = vim.diagnostic.severity.ERROR,
    },
    signs = {
      severity = vim.diagnostic.severity.WARNING,
    },
    underline = true,
    update_in_insert = false,
  })
end

return M
