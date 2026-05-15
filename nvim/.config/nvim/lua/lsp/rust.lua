-- Rust LSP Configuration (using rustaceanvim - Neovim 0.11+)
--
-- Uses rustaceanvim for superior Rust support with inlay hints
-- Required: rust-analyzer (rustup component add rust-analyzer)
--
-- Auto-formats with rustfmt on save if rustfmt.toml exists
--
-- LSP Keybindings (unified, see lsp/keymaps.lua):
--   <leader>ld   - Go to definition
--   <leader>lD   - Declarations
--   <leader>ln   - Rename symbol
--   <leader>la   - Code actions
--   <leader>li   - Implementations
--   <leader>lt   - Type definitions
--   <leader>lk   - Signature help
--   <leader>lr   - References
--   <leader>lx   - Diagnostics (Telescope)
--   K            - Hover documentation
--   [d / ]d      - Navigate diagnostics
--
-- DAP Keybindings (debugging, see dap/keymaps.lua):
--   <leader>Db   - Toggle breakpoint
--   <leader>Dc   - Continue / Start debugging
--   <leader>Do   - Step over
--   <leader>Di   - Step into
--   <leader>DO   - Step out
--   <leader>Dq   - Terminate session
--   <leader>Du   - Toggle DAP UI
--
-- Rust-specific:
--   :RustLsp inlayHints toggle  - Toggle inlay hints on/off

local M = {}

-- Guard to prevent multiple setups
if _G.rust_lsp_setup_done then
  return M
end

local on_attach = function(client, bufnr)
  -- Apply unified LSP setup from centralized config
  require("lsp").on_attach(client, bufnr)

  -- Apply DAP keybindings (debugging)
  require("dap.keymaps").apply(bufnr)
end

function M.setup()
  require("config.diagnostics").apply("lsp_clean_insert")

  -- Auto-format with rustfmt if config exists
  vim.g.rustfmt_autosave_if_config_present = 1

  -- Hook into LspAttach to apply keybindings for rust-analyzer
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("RustLspAttach", { clear = false }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client.name == "rust-analyzer" then
        on_attach(client, ev.buf)
      end
    end,
  })

  -- rustaceanvim handles all LSP setup automatically using vim.lsp.config internally
  -- It automatically sets up rust-analyzer when opening Rust files

  _G.rust_lsp_setup_done = true
end

return M
