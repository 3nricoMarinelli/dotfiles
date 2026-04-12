-- Shared diagnostic profiles to keep behavior consistent across modules.
--
-- Profiles:
--   default         - Minimal (no signs)
--   lsp_verbose     - Full feedback: signs + underlines + virtual text
--   lsp_minimal     - Clean: no signs, no virtual text
--   lsp_clean_insert - Verbose in normal mode, clean in insert mode
--                      (used universally for LSP to reduce noise while typing)

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

  -- Best of both: verbose in normal mode, clean while typing
  lsp_clean_insert = {
    signs = true,
    update_in_insert = false,  -- Don't update diagnostics while typing
    underline = true,
    severity_sort = true,
    virtual_text = {
      spacing = 4,
      prefix = "●",
    },
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
