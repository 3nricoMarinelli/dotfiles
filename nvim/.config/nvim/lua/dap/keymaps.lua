-- Unified DAP keybindings applied to all debuggable languages
-- Ensures consistent debugging UX across Python, C/C++, Rust, Typst, etc.
--
-- Core DAP Keybindings (all languages, <leader>D* namespace):
--   <leader>Db   - Toggle breakpoint
--   <leader>Dc   - Continue / Start debugging
--   <leader>Do   - Step over
--   <leader>Di   - Step into
--   <leader>DO   - Step out
--   <leader>Dq   - Terminate session
--   <leader>Du   - Toggle DAP UI
--
-- Note: Requires nvim-dap plugin to be loaded before calling apply()

local M = {}

function M.apply(bufnr)
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    return
  end

  local dapui_ok, dapui = pcall(require, "dapui")
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- ============================================================================
  -- WHICH-KEY DOCUMENTATION (register DAP group for this buffer)
  -- ============================================================================
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>D", group = "debugger", buffer = bufnr },
      { "<leader>Db", desc = "toggle breakpoint", buffer = bufnr },
      { "<leader>Dc", desc = "continue", buffer = bufnr },
      { "<leader>Do", desc = "step over", buffer = bufnr },
      { "<leader>Di", desc = "step into", buffer = bufnr },
      { "<leader>DO", desc = "step out", buffer = bufnr },
      { "<leader>Dq", desc = "terminate", buffer = bufnr },
      { "<leader>Du", desc = "toggle UI", buffer = bufnr },
    })
  end

  -- ============================================================================
  -- BREAKPOINT MANAGEMENT
  -- ============================================================================

  -- Toggle Breakpoint
  vim.keymap.set("n", "<leader>Db", function()
    dap.toggle_breakpoint()
  end, opts)

  -- ============================================================================
  -- EXECUTION CONTROL
  -- ============================================================================

  -- Continue / Start Debugging
  vim.keymap.set("n", "<leader>Dc", function()
    dap.continue()
  end, opts)

  -- Step Over
  vim.keymap.set("n", "<leader>Do", function()
    dap.step_over()
  end, opts)

  -- Step Into
  vim.keymap.set("n", "<leader>Di", function()
    dap.step_into()
  end, opts)

  -- Step Out
  vim.keymap.set("n", "<leader>DO", function()
    dap.step_out()
  end, opts)

  -- ============================================================================
  -- SESSION MANAGEMENT
  -- ============================================================================

  -- Terminate Session
  vim.keymap.set("n", "<leader>Dq", function()
    dap.terminate()
  end, opts)

  -- ============================================================================
  -- UI CONTROL
  -- ============================================================================

  -- Toggle DAP UI (if dapui is available)
  if dapui_ok then
    vim.keymap.set("n", "<leader>Du", function()
      dapui.toggle()
    end, opts)
  end
end

return M
