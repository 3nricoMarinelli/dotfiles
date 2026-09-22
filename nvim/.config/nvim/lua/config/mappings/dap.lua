-- DAP (Debug Adapter Protocol) keybindings (<leader>D* namespace)
-- Applied to all debuggable languages (C, C++, Rust, Python)

local M = {}

function M.apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr].dap_keymaps_applied then
    return
  end
  vim.b[bufnr].dap_keymaps_applied = true

  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    return
  end

  local dapui_ok, dapui = pcall(require, "dapui")
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Which-key documentation
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>Db", desc = "toggle breakpoint", buffer = bufnr },
      { "<leader>Dc", desc = "continue / start", buffer = bufnr },
      { "<leader>Do", desc = "step over", buffer = bufnr },
      { "<leader>Di", desc = "step into", buffer = bufnr },
      { "<leader>DO", desc = "step out", buffer = bufnr },
      { "<leader>Dq", desc = "terminate", buffer = bufnr },
      { "<leader>Du", desc = "toggle UI", buffer = bufnr },
    })
  end

  -- Breakpoint
  vim.keymap.set("n", "<leader>Db", function()
    dap.toggle_breakpoint()
  end, vim.tbl_extend("force", opts, { desc = "toggle breakpoint" }))

  -- Execution
  vim.keymap.set("n", "<leader>Dc", function()
    dap.continue()
  end, vim.tbl_extend("force", opts, { desc = "continue / start" }))

  vim.keymap.set("n", "<leader>Do", function()
    dap.step_over()
  end, vim.tbl_extend("force", opts, { desc = "step over" }))

  vim.keymap.set("n", "<leader>Di", function()
    dap.step_into()
  end, vim.tbl_extend("force", opts, { desc = "step into" }))

  vim.keymap.set("n", "<leader>DO", function()
    dap.step_out()
  end, vim.tbl_extend("force", opts, { desc = "step out" }))

  vim.keymap.set("n", "<leader>Dq", function()
    dap.terminate()
  end, vim.tbl_extend("force", opts, { desc = "terminate" }))

  -- UI Toggle
  if dapui_ok then
    vim.keymap.set("n", "<leader>Du", function()
      dapui.toggle()
    end, vim.tbl_extend("force", opts, { desc = "toggle UI" }))
  end
end

return M
