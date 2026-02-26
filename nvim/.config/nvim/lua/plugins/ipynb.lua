-- ipynb.lua: all .ipynb support — conversion, kernel, cell execution, highlights
--
-- Requires: pip install jupytext pynvim jupyter_client
-- Usage: just open a .ipynb file — it's converted to Python automatically,
--        LSP/treesitter/lint all apply, and the .venv kernel is available via <leader>mi.

-- Jupytext: transparent .ipynb ↔ Python conversion
local jupytext_ok, jupytext = pcall(require, "jupytext")
if not jupytext_ok then return end

jupytext.setup({
    style            = "light",    -- minimal cell markers (# %%)
    output_extension = "auto",     -- keep original extension on save
    force_ft         = "python",   -- always treat as Python for LSP

    -- Per-format overrides
    custom_language_formatting = {
        python = {
            extension        = "py",
            style            = "percent",  -- use # %% cell markers (Jupyter percent format)
            force_ft         = "python",
        },
    },
})

-- Walk parent directories to find the nearest uv project root (.venv)
local function find_venv_root()
    local path = vim.fn.expand("%:p:h")
    while path ~= "/" do
        if vim.fn.isdirectory(path .. "/.venv") == 1 then
            return path
        end
        path = vim.fn.fnamemodify(path, ":h")
    end
end

-- Register the .venv as a Jupyter kernel via uv, then init Molten with it.
-- Falls back to the interactive picker if no .venv is found.
local function init_venv_kernel()
    local root = find_venv_root()
    if not root then
        vim.notify("molten: no .venv found, opening kernel picker", vim.log.levels.WARN)
        vim.cmd("MoltenInit")
        return
    end

    local name = vim.fn.fnamemodify(root, ":t")
    -- --with ipykernel: no need to add ipykernel to the project deps
    local ok = vim.fn.system(string.format(
        "cd %s && uv run --with ipykernel python -m ipykernel install --user --name %s 2>&1",
        vim.fn.shellescape(root), vim.fn.shellescape(name)
    ))
    if vim.v.shell_error ~= 0 then
        vim.notify("molten: kernel registration failed:\n" .. ok, vim.log.levels.ERROR)
        return
    end
    vim.cmd("MoltenInit " .. name)
end

-- Run the cell under the cursor (bounded by # %% markers)
local function run_current_cell()
    local line  = vim.fn.line(".")
    local total = vim.fn.line("$")

    local start_line = 1
    for i = line, 1, -1 do
        if vim.fn.getline(i):match("^# %%") then
            start_line = i + 1
            break
        end
    end

    local end_line = total
    for i = line + 1, total do
        if vim.fn.getline(i):match("^# %%") then
            end_line = i - 1
            break
        end
    end

    while end_line > start_line and vim.fn.getline(end_line):match("^%s*$") do
        end_line = end_line - 1
    end

    if start_line > end_line then return end

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(
            string.format("%dggV%dgg:<C-u>MoltenEvaluateVisual<CR>", start_line, end_line),
            true, false, true
        ), "n", false
    )
end

vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python", "quarto" },
    once     = true,
    callback = function()
        vim.keymap.set("n", "<leader>mi", init_venv_kernel, { desc = "Molten: Init .venv kernel" })
        vim.keymap.set("n", "<leader>mc", run_current_cell,  { desc = "Molten: Run current cell" })
    end,
})

-- Visually distinguish code / markdown / raw cell delimiters
vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python", "quarto" },
    callback = function()
        vim.fn.matchadd("Statement", [[^# %% \[markdown\].*]])
        vim.fn.matchadd("Comment",   [[^# %% \[raw\].*]])
        vim.fn.matchadd("Title",     [[^# %%\( \[markdown\]\| \[raw\]\)\@!.*]])
    end,
})

-- Walk parent directories to find the nearest uv project root (.venv)
local function find_venv_root()
    local path = vim.fn.expand("%:p:h")
    while path ~= "/" do
        if vim.fn.isdirectory(path .. "/.venv") == 1 then
            return path
        end
        path = vim.fn.fnamemodify(path, ":h")
    end
end

-- Register the .venv as a Jupyter kernel via uv, then init Molten with it.
-- Falls back to the interactive picker if no .venv is found.
local function init_venv_kernel()
    local root = find_venv_root()
    if not root then
        vim.notify("molten: no .venv found, opening kernel picker", vim.log.levels.WARN)
        vim.cmd("MoltenInit")
        return
    end

    local name = vim.fn.fnamemodify(root, ":t")
    -- --with ipykernel: no need to add ipykernel to the project deps
    local ok = vim.fn.system(string.format(
        "cd %s && uv run --with ipykernel python -m ipykernel install --user --name %s 2>&1",
        vim.fn.shellescape(root), vim.fn.shellescape(name)
    ))
    if vim.v.shell_error ~= 0 then
        vim.notify("molten: kernel registration failed:\n" .. ok, vim.log.levels.ERROR)
        return
    end
    vim.cmd("MoltenInit " .. name)
end

-- Run the cell under the cursor (bounded by # %% markers)
local function run_current_cell()
    local line  = vim.fn.line(".")
    local total = vim.fn.line("$")

    local start_line = 1
    for i = line, 1, -1 do
        if vim.fn.getline(i):match("^# %%") then
            start_line = i + 1
            break
        end
    end

    local end_line = total
    for i = line + 1, total do
        if vim.fn.getline(i):match("^# %%") then
            end_line = i - 1
            break
        end
    end

    while end_line > start_line and vim.fn.getline(end_line):match("^%s*$") do
        end_line = end_line - 1
    end

    if start_line > end_line then return end

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(
            string.format("%dggV%dgg:<C-u>MoltenEvaluateVisual<CR>", start_line, end_line),
            true, false, true
        ), "n", false
    )
end

vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python", "quarto" },
    once     = true,
    callback = function()
        vim.keymap.set("n", "<leader>mi", init_venv_kernel, { desc = "Molten: Init .venv kernel" })
        vim.keymap.set("n", "<leader>mc", run_current_cell,  { desc = "Molten: Run current cell" })
    end,
})

-- Visually distinguish code / markdown / raw cell delimiters
vim.api.nvim_create_autocmd("FileType", {
    pattern  = { "python", "quarto" },
    callback = function()
        vim.fn.matchadd("Statement", [[^# %% \[markdown\].*]])
        vim.fn.matchadd("Comment",   [[^# %% \[raw\].*]])
        vim.fn.matchadd("Title",     [[^# %%\( \[markdown\]\| \[raw\]\)\@!.*]])
    end,
})
