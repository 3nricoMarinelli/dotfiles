-- Unified LSP keybindings applied to all languages
-- Ensures consistent UX across C/C++, Python, Rust, Typst, etc.
--
-- Core LSP Keybindings (all languages):
--   <leader>ld   - Go to definition
--   <leader>]    - Go to definition (alias, cacharle style)
--   <leader>lD   - Declarations
--   <leader>[    - Declarations (alias, cacharle style)
--   K            - Hover documentation
--   <leader>lk   - Signature help
--   gk           - Signature help (alias, cacharle style)
--   <leader>r    - Rename symbol
--   <leader>rn   - Rename symbol (alias, cacharle style)
--   <leader>la   - Code actions
--   <leader>li   - Implementations
--   <leader>lt   - Type definitions
--   <leader>lr   - References
--   <leader>lx   - Diagnostics (Telescope)
--   <leader>q    - Diagnostics (alias, cacharle style)
--   <leader>p    - Workspace symbols (Telescope)
--   [d / ]d      - Navigate diagnostics (prev/next)

local M = {}

function M.apply(bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- ============================================================================
    -- CORE LSP NAVIGATION
    -- ============================================================================
    
    -- Definition (multiple aliases for consistency)
    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>]", vim.lsp.buf.definition, opts)  -- cacharle style
    
    -- Declaration (multiple aliases for consistency)
    vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "<leader>[", vim.lsp.buf.declaration, opts)  -- cacharle style
    
    -- Hover Documentation
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    
    -- Signature Help (multiple aliases)
    vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)      -- cacharle style
    
    -- ============================================================================
    -- REFACTORING & CODE ACTIONS
    -- ============================================================================
    
    -- Rename (multiple aliases)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)      -- cacharle style
    
    -- Code Actions (works across all LSPs)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set("v", "<leader>la", vim.lsp.buf.code_action, opts)
    
    -- ============================================================================
    -- DISCOVERY & NAVIGATION
    -- ============================================================================
    
    -- Implementations
    vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, opts)
    
    -- Type Definitions
    vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)
    
    -- References
    local has_telescope = pcall(require, "telescope")
    if has_telescope then
        vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)
    else
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
    end
    
    -- Workspace Symbols (NEW - useful for exploration)
    if has_telescope then
        vim.keymap.set("n", "<leader>p", "<cmd>Telescope lsp_workspace_symbols<CR>", opts)
    end
    
    -- ============================================================================
    -- DIAGNOSTICS
    -- ============================================================================
    
    -- Navigate Diagnostics
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    
    -- List Diagnostics (multiple aliases for consistency)
    if has_telescope then
        vim.keymap.set("n", "<leader>lx", "<cmd>Telescope diagnostics<CR>", opts)
        vim.keymap.set("n", "<leader>q", "<cmd>Telescope diagnostics<CR>", opts)  -- cacharle style
    else
        vim.keymap.set("n", "<leader>lx", vim.diagnostic.setloclist, opts)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
    end
end

return M
