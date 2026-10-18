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
  require("config.mappings.dap").apply(bufnr)
end

function M.setup()
  require("config.diagnostics").apply("lsp_clean_insert")

  -- Auto-format with rustfmt if config exists
  vim.g.rustfmt_autosave_if_config_present = 1

  -- Configure rustaceanvim to use the active rustup toolchain's rust-analyzer
  vim.g.rustaceanvim = {
    server = {
      on_attach = on_attach,
      cmd = function()
        local ra = vim.fn.trim(vim.fn.system({ "rustup", "which", "rust-analyzer" }))
        if vim.v.shell_error == 0 and #ra > 0 and vim.fn.executable(ra) == 1 then
          return { ra }
        end
        return { "rust-analyzer" }
      end,
    },
  }

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

  _G.rust_lsp_setup_done = true
end

return M
