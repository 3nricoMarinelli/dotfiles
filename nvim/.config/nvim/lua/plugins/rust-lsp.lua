-- Rust LSP Configuration (using rustaceanvim - Neovim 0.11+)
--
-- Uses rustaceanvim for superior Rust support with inlay hints
-- Required: rust-analyzer (rustup component add rust-analyzer)
--
-- Auto-formats with rustfmt on save if rustfmt.toml exists
--
-- LSP Keybindings (same as other languages)
-- Toggle inlay hints: :lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())

local M = {}

-- Guard to prevent multiple setups
if _G.rust_lsp_setup_done then
    return M
end

function M.setup()
    local rustaceanvim_ok = pcall(require, "rustaceanvim")
    if not rustaceanvim_ok then
        vim.notify("rustaceanvim not loaded", vim.log.levels.WARN)
        return
    end

    vim.diagnostic.config({ signs = false, update_in_insert = false })
    
    -- Auto-format with rustfmt if config exists
    vim.g.rustfmt_autosave_if_config_present = 1
    
    -- rustaceanvim handles all LSP setup automatically using vim.lsp.config internally
    -- It automatically sets up rust-analyzer when opening Rust files
    
    _G.rust_lsp_setup_done = true
end

return M
