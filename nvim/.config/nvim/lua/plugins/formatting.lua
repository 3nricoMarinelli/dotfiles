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
