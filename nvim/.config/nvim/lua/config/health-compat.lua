-- Compatibility shim for plugins still using pre-0.12 vim.health API names.

if vim.health then
  vim.health.report_start = vim.health.report_start or vim.health.start
  vim.health.report_ok = vim.health.report_ok or vim.health.ok
  vim.health.report_warn = vim.health.report_warn or vim.health.warn
  vim.health.report_error = vim.health.report_error or vim.health.error
end
