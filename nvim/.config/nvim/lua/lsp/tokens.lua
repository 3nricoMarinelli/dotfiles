-- Neovim 0.12+ Semantic Tokens Configuration
-- Provides LSP-based syntax highlighting with better type/variable/function distinction

local M = {}

--- Setup semantic token highlight groups
local function setup_highlights()
  -- Define highlight groups for semantic tokens
  local highlights = {
    -- Types
    ["@lsp.type.class"] = "Type",
    ["@lsp.type.struct"] = "Type",
    ["@lsp.type.enum"] = "Type",
    ["@lsp.type.interface"] = "Type",
    ["@lsp.type.typedef"] = "Type",
    ["@lsp.type.union"] = "Type",

    -- Variables
    ["@lsp.type.variable"] = "Identifier",
    ["@lsp.type.parameter"] = "Identifier",
    ["@lsp.type.property"] = "Identifier",
    ["@lsp.type.enumMember"] = "Constant",

    -- Functions
    ["@lsp.type.function"] = "Function",
    ["@lsp.type.method"] = "Function",

    -- Keywords
    ["@lsp.type.keyword"] = "Keyword",
    ["@lsp.type.modifier"] = "Keyword",

    -- Comments
    ["@lsp.type.comment"] = "Comment",
    ["@lsp.type.string"] = "String",
    ["@lsp.type.number"] = "Number",
    ["@lsp.type.regexp"] = "String",
    ["@lsp.type.operator"] = "Operator",

    -- Namespaces
    ["@lsp.type.namespace"] = "Identifier",
    ["@lsp.type.module"] = "Identifier",
    ["@lsp.type.package"] = "Identifier",
  }

  -- Apply highlights
  for token, hl_group in pairs(highlights) do
    vim.api.nvim_set_hl(0, token, { link = hl_group, default = true })
  end
end

--- Setup semantic tokens on_attach handler
--- Call this from LSP on_attach callback
--- @param client any LSP client
--- @param bufnr number Buffer number
function M.on_attach(client, bufnr)
  if client.server_capabilities.semanticTokensProvider then
    vim.lsp.semantic_tokens.enable(true, { bufnr = bufnr })
  end
end

--- Initialize semantic tokens (called from init.lua)
function M.setup()
  if not vim.lsp.semantic_tokens then
    vim.notify("Semantic tokens not available in this Neovim version", vim.log.levels.WARN)
    return
  end

  setup_highlights()
end

return M
