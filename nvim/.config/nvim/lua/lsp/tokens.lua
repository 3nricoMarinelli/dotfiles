-- Neovim 0.12+ Semantic Tokens Configuration
-- Provides LSP-based syntax highlighting with better type/variable/function distinction

local M = {}

--- Setup semantic token highlight groups
local function setup_highlights()
    -- Define highlight groups for semantic tokens
    local highlights = {
        -- TODO improve
        -- Types
        ["@lsp.type.class"] = "@type",
        ["@lsp.type.struct"] = "@type",
        ["@lsp.type.enum"] = "@type",
        ["@lsp.type.interface"] = "@type",
        ["@lsp.type.typedef"] = "@type",
        ["@lsp.type.union"] = "@type",

        -- Variables
        ["@lsp.type.variable"] = "@variable",
        ["@lsp.type.parameter"] = "@parameter",
        ["@lsp.type.property"] = "@property",
        ["@lsp.type.enumMember"] = "@constant",

        -- Functions
        ["@lsp.type.function"] = "@function",
        ["@lsp.type.method"] = "@function",

        -- Keywords
        ["@lsp.type.keyword"] = "@keyword",
        ["@lsp.type.modifier"] = "@keyword",

        -- Comments
        ["@lsp.type.comment"] = "@comment",
        ["@lsp.type.string"] = "@string",
        ["@lsp.type.number"] = "@number",
        ["@lsp.type.regexp"] = "@string",
        ["@lsp.type.operator"] = "@operator",

        -- Namespaces
        ["@lsp.type.namespace"] = "@module",
        ["@lsp.type.module"] = "@module",
        ["@lsp.type.package"] = "@module",
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
