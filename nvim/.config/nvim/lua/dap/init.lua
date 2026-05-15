-- DAP (Debug Adapter Protocol) initialization
-- Sets up nvim-dap with UI, virtual text, and per-language configuration
--
-- Requires:
--   - nvim-dap (main plugin)
--   - nvim-dap-ui (optional, for UI)
--   - nvim-dap-virtual-text (optional, for inline variable display)
--
-- Usage:
--   require("dap.init").setup()        -- Called automatically on plugin load
--   require("dap.keymaps").apply(bufnr)  -- Called per-buffer by language LSP files

local M = {}

function M.setup()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    return
  end

  local dapui_ok, dapui = pcall(require, "dapui")
  local dap_vtext_ok = pcall(require, "nvim-dap-virtual-text")

  -- ============================================================================
  -- BREAKPOINT SIGNS (UI indicators for breakpoints) - safe to do early
  -- ============================================================================
  vim.fn.sign_define("DapBreakpoint", {
    text = "",
    texthl = "DiagnosticSignError",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapBreakpointRejected", {
    text = "",
    texthl = "DiagnosticSignError",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DiagnosticSignWarn",
    linehl = "Visual",
    numhl = "DiagnosticSignWarn",
  })

  -- ============================================================================
  -- DAP UI AUTO-OPEN (manual listener registration)
  -- Skip dapui.setup() - let Lazy handle it. Just register our listeners manually.
  -- ============================================================================
  if dapui_ok then
    -- Register listeners with graceful error handling
    -- Defer by 200ms to ensure dap.listeners exists
    vim.defer_fn(function()
      if dap.listeners and type(dap.listeners) == "table" then
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end
    end, 200)  -- Defer by 200ms for safety
  end
end

return M
