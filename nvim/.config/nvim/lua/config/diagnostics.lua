-- Shared diagnostic profiles to keep behavior consistent across modules.

local M = {}

M.profiles = {
  default = {
    signs = false,
  },

  lsp_verbose = {
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    virtual_text = {
      spacing = 4,
      prefix = "●",
    },
  },

  lsp_minimal = {
    signs = false,
    update_in_insert = false,
  },
}

function M.apply(profile_name, overrides)
  local profile = vim.deepcopy(M.profiles[profile_name] or {})
  if overrides then
    profile = vim.tbl_deep_extend("force", profile, overrides)
  end
  vim.diagnostic.config(profile)
end

return M
