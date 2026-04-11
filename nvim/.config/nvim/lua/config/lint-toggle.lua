-- Linting Toggle Configuration
-- Keeps current behavior: lint always runs on write (see autocmd.lua).
-- This toggle controls *extra* lint triggers on text-change/insert-leave.

vim.g.lint_enabled = false -- disabled by default

local function toggle_lint()
    if vim.g.lint_enabled then
        vim.g.lint_enabled = false
        vim.notify("Extra lint-on-change disabled (write lint stays on)", vim.log.levels.INFO)
    else
        vim.g.lint_enabled = true
        vim.notify("Extra lint-on-change enabled", vim.log.levels.INFO)
    end
end

vim.api.nvim_create_user_command("ToggleLint", toggle_lint, {})
-- Use <leader>ll to avoid overlap with tree prefix (<leader>t)
vim.keymap.set("n", "<leader>ll", toggle_lint, { desc = "Toggle linting" })

-- Extra linting autocmd - only runs if explicitly enabled.
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("LintOnSave", { clear = false }),
    callback = function()
        if vim.g.lint_enabled then
            require("lint").try_lint()
        end
    end,
})
