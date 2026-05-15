-- Formatting backend (Conform)
-- User preference: format-on-save enabled.

local conform_ok, conform = pcall(require, "conform")
if not conform_ok then
  return
end

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    rust = { "rustfmt" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },
  formatters = {
    prettier = {
      prepend_args = { "--tab-width", "2" },
    },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
  notify_on_error = true,
})

-- ============================================================================
-- WRITE WITHOUT FORMAT COMMAND (wnf)
-- ============================================================================
-- User command :wnf = :NoFormat + :w (write without formatting)
-- Useful for quick saves without triggering format-on-save

-- Global flag to skip formatting on next save
vim.g.skip_format = false

-- Hook into BufWritePre to check skip flag
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("SkipFormatCheck", { clear = true }),
  callback = function()
    if vim.g.skip_format then
      -- Temporarily disable format_on_save
      conform.setup({
        format_on_save = nil,
      })
      vim.g.skip_format = false
      vim.notify("Format skipped for this save", vim.log.levels.INFO)
    end
  end,
})

-- Re-enable formatting after write
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("ReenableFormat", { clear = true }),
  callback = function()
    conform.setup({
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    })
  end,
})

-- :wnf command - write without formatting
vim.api.nvim_create_user_command("Wnf", function()
  vim.g.skip_format = true
  vim.cmd("w")
end, { desc = "Write without formatting" })
