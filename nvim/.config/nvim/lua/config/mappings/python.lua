-- Python & Jupyter Molten REPL keybindings (<leader>p* namespace)
-- Streamlined to the 4 essential actions

local M = {}

function M.apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr].python_keymaps_applied then
    return
  end
  vim.b[bufnr].python_keymaps_applied = true

  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Which-key documentation
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>pi", desc = "init kernel", buffer = bufnr },
      { "<leader>pc", desc = "run current cell", buffer = bufnr },
      { "<leader>po", desc = "output window", buffer = bufnr },
      { "<leader>pv", desc = "view plot in Preview", buffer = bufnr },
    })
  end

  local function get_py()
    local ok, py = pcall(require, "plugins.python")
    return ok and py or {}
  end

  -- Kernel initialization
  vim.keymap.set("n", "<leader>pi", function()
    local py = get_py()
    if py.init_venv_kernel then
      py.init_venv_kernel()
    else
      vim.cmd("MoltenInit")
    end
  end, vim.tbl_extend("force", opts, { desc = "Molten: Init kernel" }))

  -- Run current cell
  vim.keymap.set("n", "<leader>pc", function()
    local py = get_py()
    if py.run_current_cell then
      py.run_current_cell()
    end
  end, vim.tbl_extend("force", opts, { desc = "Molten: Run current cell" }))

  -- Output window (enter floating window to scroll / inspect)
  vim.keymap.set("n", "<leader>po", ":noautocmd MoltenEnterOutput<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Enter output window" }))

  -- External image viewer fallback (<leader>pv opens plot in macOS Preview)
  local viewer_ok, viewer = pcall(require, "plugins.molten-fallback-viewer")
  if viewer_ok and viewer.open_image_externally then
    vim.keymap.set("n", "<leader>pv", viewer.open_image_externally, vim.tbl_extend("force", opts, { desc = "Molten: View plot in Preview" }))
  end
end

return M
