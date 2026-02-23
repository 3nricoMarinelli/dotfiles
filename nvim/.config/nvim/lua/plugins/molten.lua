-- Molten: Jupyter notebook interactive execution inside Neovim
-- Requires Python packages: pip install pynvim jupyter_client
-- Optional (for image output): pip install cairosvg plotly kaleido
--
-- Workflow:
--   1. Open a .py file or a .ipynb file (jupytext.nvim converts it)
--   2. <leader>mi  - Initialize molten (choose kernel)
--   3. <leader>me  - Evaluate cell under cursor
--   4. <leader>mr  - Re-evaluate all cells
--   5. <leader>mo  - Show output window
--   6. <leader>mx  - Interrupt kernel
--   7. <leader>mq  - Deinit (stop kernel)
--
-- Cell delimiters (compatible with jupytext percent format):
--   # %% (Python)  or  # In[N]: (Jupyter-exported)

-- Basic display settings
vim.g.molten_auto_open_output     = false   -- don't auto-open output pane; toggle with <leader>mo
vim.g.molten_output_win_max_height = 20
vim.g.molten_virt_text_output     = true    -- show truncated output as virtual text
vim.g.molten_virt_lines_off_by_1  = true
vim.g.molten_wrap_output          = true
vim.g.molten_image_provider       = "none"  -- set to "image.nvim" if image.nvim is installed

-- Keybindings (only set once; molten must be loaded)
local function setup_molten_keymaps()
    local opts = { noremap = true, silent = true }

    vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>",                    vim.tbl_extend("force", opts, { desc = "Molten: Init kernel" }))
    vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>",        vim.tbl_extend("force", opts, { desc = "Molten: Evaluate operator" }))
    vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>",            vim.tbl_extend("force", opts, { desc = "Molten: Evaluate line" }))
    vim.keymap.set("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>",     vim.tbl_extend("force", opts, { desc = "Molten: Evaluate visual selection" }))
    vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>",          vim.tbl_extend("force", opts, { desc = "Molten: Re-evaluate cell" }))
    vim.keymap.set("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>",   vim.tbl_extend("force", opts, { desc = "Molten: Enter output window" }))
    vim.keymap.set("n", "<leader>mx", ":MoltenInterrupt<CR>",               vim.tbl_extend("force", opts, { desc = "Molten: Interrupt kernel" }))
    vim.keymap.set("n", "<leader>mq", ":MoltenDeinit<CR>",                  vim.tbl_extend("force", opts, { desc = "Molten: Deinit kernel" }))
    vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>",                  vim.tbl_extend("force", opts, { desc = "Molten: Delete cell output" }))
    vim.keymap.set("n", "]m", ":MoltenNext<CR>",                            vim.tbl_extend("force", opts, { desc = "Molten: Next cell" }))
    vim.keymap.set("n", "[m", ":MoltenPrev<CR>",                            vim.tbl_extend("force", opts, { desc = "Molten: Previous cell" }))
end

-- Set up keymaps when entering Python or Quarto files
vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python", "quarto" },
    once     = true,
    callback = setup_molten_keymaps,
})
