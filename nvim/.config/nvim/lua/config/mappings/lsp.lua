-- LSP keybindings applied to all language servers (<leader>l* namespace)

local M = {}

function M.apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr].lsp_keymaps_applied then
    return
  end
  vim.b[bufnr].lsp_keymaps_applied = true

  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Which-key documentation
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>ld", desc = "go definition", buffer = bufnr },
      { "<leader>lD", desc = "go declaration", buffer = bufnr },
      { "<leader>ln", desc = "rename symbol", buffer = bufnr },
      { "<leader>la", desc = "code action", mode = { "n", "v" }, buffer = bufnr },
      { "<leader>li", desc = "implementations", buffer = bufnr },
      { "<leader>lt", desc = "type definition", buffer = bufnr },
      { "<leader>lr", desc = "show references", buffer = bufnr },
      { "<leader>lx", desc = "list diagnostics", buffer = bufnr },
      { "<leader>lk", desc = "signature help", buffer = bufnr },
      { "<leader>lh", desc = "toggle hints", buffer = bufnr },
    })
  end

  -- Navigation
  vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "go definition" }))
  vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "go declaration" }))
  vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "hover docs" }))
  vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "signature help" }))

  -- Refactoring & Actions
  vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "rename symbol" }))
  vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "code action" }))

  -- Discovery
  vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "implementations" }))
  vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "type definition" }))

  local has_telescope = pcall(require, "telescope")
  if has_telescope then
    vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", vim.tbl_extend("force", opts, { desc = "show references" }))
    vim.keymap.set("n", "<leader>lx", "<cmd>Telescope diagnostics<CR>", vim.tbl_extend("force", opts, { desc = "list diagnostics" }))
  else
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "show references" }))
    vim.keymap.set("n", "<leader>lx", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "list diagnostics" }))
  end

  -- Diagnostic jumps
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "prev diagnostic" }))
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "next diagnostic" }))

  -- Inlay hints toggle
  vim.keymap.set("n", "<leader>lh", function()
    require("lsp.hints").toggle_inlay_hints()
  end, vim.tbl_extend("force", opts, { desc = "toggle hints" }))
end

return M
