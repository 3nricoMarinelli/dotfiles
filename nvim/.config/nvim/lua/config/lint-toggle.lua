-- Linting Configuration
-- Linting is available in supported languages: python, c, cpp
-- Use ruff for Python, clang-tidy + cppcheck for C/C++
--
-- Linting keybindings:
--   <leader>ll  - Show lint diagnostics (buffer-scoped, only in supported filetypes)
-- 
-- This file configures:
--   - Linting on save (always enabled for supported filetypes)
--   - Extra linting on text-change/insert-leave (toggle via :ToggleLint)

-- Supported languages for linting
local LINTER_LANGS = {
  python = true,
  c = true,
  cpp = true,
}

vim.g.lint_enabled = false -- disabled by default (only lint on save)

local function toggle_lint()
  if vim.g.lint_enabled then
    vim.g.lint_enabled = false
    vim.notify("Extra lint-on-change disabled (save lint stays on)", vim.log.levels.INFO)
  else
    vim.g.lint_enabled = true
    vim.notify("Extra lint-on-change enabled", vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command("ToggleLint", toggle_lint, {})

-- Extra linting autocmd - only runs if explicitly enabled, and only in supported filetypes.
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("LintOnChange", { clear = true }),
  callback = function()
    local filetype = vim.bo.filetype
    if vim.g.lint_enabled and LINTER_LANGS[filetype] then
      require("lint").try_lint()
    end
  end,
})
