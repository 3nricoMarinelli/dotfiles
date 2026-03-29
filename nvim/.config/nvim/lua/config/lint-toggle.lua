-- Linting Toggle Configuration
-- Disabled by default - use :ToggleLint to enable
-- Can also set: vim.g.lint_enabled = true to enable on startup

vim.g.lint_enabled = false -- disabled by default

local function toggle_lint()
    if vim.g.lint_enabled then
        vim.g.lint_enabled = false
        vim.cmd("LintDisable")
        vim.notify("Linting disabled", vim.log.levels.INFO)
    else
        vim.g.lint_enabled = true
        vim.cmd("LintEnable")
        vim.notify("Linting enabled", vim.log.levels.INFO)
    end
end

vim.api.nvim_create_user_command("ToggleLint", toggle_lint, {})
vim.keymap.set("n", "<leader>tl", toggle_lint, { desc = "Toggle linting" })

-- Linting autocmd - only runs if linting is enabled
vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("LintOnSave", { clear = false }),
    callback = function()
        if vim.g.lint_enabled then
            require("lint").try_lint()
        end
    end,
})