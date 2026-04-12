-- Unified LSP keybindings applied to all languages
-- Ensures consistent UX across C/C++, Python, Rust, Typst, etc.
--
-- Core LSP Keybindings (all languages):
--   <leader>ld  - Go to definition
--   K           - Hover documentation
--   <leader>lk  - Signature help
--   <leader>r   - Rename symbol
--   <leader>la  - Code actions
--   <leader>li  - Implementations
--   <leader>lt  - Type definitions
--   <leader>lD  - Declarations
--   <leader>lr  - References
--   <leader>lx  - Diagnostics (Telescope)
--   [d / ]d     - Navigate diagnostics (prev/next)

local M = {}

function M.apply(bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- Navigation: Definition
    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)
    
    -- Navigation: Hover
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    
    -- Navigation: Signature Help
    vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help, opts)
    
    -- Refactoring: Rename
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
    
    -- Refactoring: Code Actions (works across all LSPs)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set("v", "<leader>la", vim.lsp.buf.code_action, opts)
    
    -- Discovery: Implementations
    vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, opts)
    
    -- Discovery: Type Definitions
    vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)
    
    -- Discovery: Declarations
    vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, opts)
    
    -- Diagnostics: Navigate
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    
    -- Diagnostics: List (Telescope or fallback)
    local has_telescope = pcall(require, "telescope")
    if has_telescope then
        vim.keymap.set("n", "<leader>lx", "<cmd>Telescope diagnostics<CR>", opts)
        vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)
    else
        vim.keymap.set("n", "<leader>lx", vim.diagnostic.setloclist, opts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
    end
end

return M
