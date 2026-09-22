-- Compatibility shim for plugins still using pre-0.12 APIs

-- 1. vim.health legacy method names (report_start, report_ok, etc.)
if vim.health then
  vim.health.report_start = vim.health.report_start or vim.health.start
  vim.health.report_ok = vim.health.report_ok or vim.health.ok
  vim.health.report_warn = vim.health.report_warn or vim.health.warn
  vim.health.report_error = vim.health.report_error or vim.health.error
end

-- 2. vim.validate compatibility for plugins still passing legacy table spec (e.g. jupytext.nvim)
-- Forward table specifications to modern positional vim.validate(name, val, validator, optional)
-- to prevent triggering vim.deprecate warnings in checkhealth.
local orig_validate = vim.validate
if orig_validate then
  vim.validate = function(name, value, validator, optional, message)
    if type(name) == "table" and validator == nil then
      for opt_name, spec in pairs(name) do
        if type(spec) == "table" then
          orig_validate(opt_name, spec[1], spec[2], spec[3], spec[4])
        else
          orig_validate(opt_name, spec)
        end
      end
      return
    end
    return orig_validate(name, value, validator, optional, message)
  end
end
