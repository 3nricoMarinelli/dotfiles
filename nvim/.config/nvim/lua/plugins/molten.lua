-- Molten: Jupyter notebook interactive execution inside Neovim
-- Requires Python packages: pip install pynvim jupyter_client
-- Optional (for image output): pip install cairosvg plotly kaleido
--
-- Workflow:
--   1. Open a .ipynb file (jupytext.nvim converts it, ipynb.lua inits the kernel)
--   2. <leader>mi  - Init .venv kernel (see ipynb.lua)
--   3. <leader>mc  - Run cell under cursor (see ipynb.lua)
--   4. <leader>me  - Evaluate operator / visual selection
--   5. <leader>mr  - Re-evaluate cell
--   6. <leader>mo  - Show output window
--   7. <leader>mx  - Interrupt kernel
--   8. <leader>mq  - Deinit (stop kernel)

-- Basic display settings
vim.g.molten_auto_open_output      = false
vim.g.molten_output_win_max_height = 20
vim.g.molten_virt_text_output      = true
vim.g.molten_virt_lines_off_by_1   = true
vim.g.molten_wrap_output           = true
vim.g.molten_image_provider        = "none"  -- set to "image.nvim" if image.nvim is installed

vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python", "quarto" },
    once     = true,
    callback = function()
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>",      vim.tbl_extend("force", opts, { desc = "Molten: Evaluate operator" }))
        vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>",          vim.tbl_extend("force", opts, { desc = "Molten: Evaluate line" }))
        vim.keymap.set("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>",   vim.tbl_extend("force", opts, { desc = "Molten: Evaluate visual selection" }))
        vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>",        vim.tbl_extend("force", opts, { desc = "Molten: Re-evaluate cell" }))
        vim.keymap.set("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>", vim.tbl_extend("force", opts, { desc = "Molten: Enter output window" }))
        vim.keymap.set("n", "<leader>mx", ":MoltenInterrupt<CR>",             vim.tbl_extend("force", opts, { desc = "Molten: Interrupt kernel" }))
        vim.keymap.set("n", "<leader>mq", ":MoltenDeinit<CR>",                vim.tbl_extend("force", opts, { desc = "Molten: Deinit kernel" }))
        vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>",                vim.tbl_extend("force", opts, { desc = "Molten: Delete cell output" }))
        vim.keymap.set("n", "]m",         ":MoltenNext<CR>",                  vim.tbl_extend("force", opts, { desc = "Molten: Next cell" }))
        vim.keymap.set("n", "[m",         ":MoltenPrev<CR>",                  vim.tbl_extend("force", opts, { desc = "Molten: Previous cell" }))
    end,
})
