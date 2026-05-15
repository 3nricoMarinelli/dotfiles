-- python.lua: Python & Jupyter notebook support
-- Handles: .py files, .ipynb files (via Jupytext), and Quarto notebooks
-- Features: LSP, DAP, Molten REPL, cell execution, which-key docs
--
-- Requires: pip install jupytext pynvim jupyter_client
-- Usage: Open any .py, .ipynb, or .qmd file with # %% cells
--        All LSP/treesitter/lint/DAP/Molten keybindings available via <leader>p*

-- Jupytext: transparent .ipynb ↔ Python conversion
local jupytext_ok, jupytext = pcall(require, "jupytext")
if not jupytext_ok then
  return
end

jupytext.setup({
  style = "light", -- minimal cell markers (# %%)
  output_extension = "auto", -- keep original extension on save
  force_ft = "python", -- always treat as Python for LSP

  -- Per-format overrides
  custom_language_formatting = {
    python = {
      extension = "py",
      style = "percent", -- use # %% cell markers (Jupyter percent format)
      force_ft = "python",
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
  local ok = vim.fn.system(
    string.format(
      "cd %s && uv run --with ipykernel python -m ipykernel install --user --name %s 2>&1",
      vim.fn.shellescape(root),
      vim.fn.shellescape(name)
    )
  )
  if vim.v.shell_error ~= 0 then
    vim.notify("molten: kernel registration failed:\n" .. ok, vim.log.levels.ERROR)
    return
  end
  vim.cmd("MoltenInit " .. name)
end

-- Run the cell under the cursor (bounded by # %% markers)
local function run_current_cell()
  local line = vim.fn.line(".")
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

  if start_line > end_line then
    return
  end

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(
      string.format("%dggV%dgg:<C-u>MoltenEvaluateVisual<CR>", start_line, end_line),
      true,
      false,
      true
    ),
    "n",
    false
  )
end

-- ============================================================================
-- MOLTEN & JUPYTER KEYBINDINGS (Buffer-local, <leader>p* namespace)
-- Activated on FileType python/quarto for .py, .ipynb, and Quarto files
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "quarto" },
  callback = function()
    local opts = { noremap = true, silent = true }

    -- Kernel initialization (Python-specific)
    vim.keymap.set(
      "n",
      "<leader>pi",
      init_venv_kernel,
      vim.tbl_extend("force", opts, { desc = "Molten: Init .venv kernel" })
    )

    -- Cell execution (Python-specific)
    vim.keymap.set(
      "n",
      "<leader>pc",
      run_current_cell,
      vim.tbl_extend("force", opts, { desc = "Molten: Run current cell" })
    )

    -- Evaluate operator (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>pe",
      ":MoltenEvaluateOperator<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Evaluate operator" })
    )

    -- Evaluate visual selection (works in Python and notebook cells)
    vim.keymap.set(
      "v",
      "<leader>pe",
      ":<C-u>MoltenEvaluateVisual<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Evaluate visual selection" })
    )

    -- Evaluate line (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>pl",
      ":MoltenEvaluateLine<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Evaluate line" })
    )

    -- Re-evaluate cell (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>pr",
      ":MoltenReevaluateCell<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Re-evaluate cell" })
    )

    -- Output window (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>po",
      ":noautocmd MoltenEnterOutput<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Enter output window" })
    )

    -- Interrupt kernel (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>px",
      ":MoltenInterrupt<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Interrupt kernel" })
    )

    -- Deinit kernel (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>pq",
      ":MoltenDeinit<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Deinit kernel" })
    )

    -- Delete cell output (works in Python and notebook cells)
    vim.keymap.set(
      "n",
      "<leader>pd",
      ":MoltenDelete<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Delete cell output" })
    )

    -- Cell navigation
    vim.keymap.set(
      "n",
      "]p",
      ":MoltenNext<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Next cell" })
    )
    vim.keymap.set(
      "n",
      "[p",
      ":MoltenPrev<CR>",
      vim.tbl_extend("force", opts, { desc = "Molten: Previous cell" })
    )
  end,
})

-- ============================================================================
-- WHICH-KEY DOCUMENTATION (Buffer-local, <leader>p* namespace)
-- Only register group when FileType is python or quarto
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "quarto" },
  once = false,
  callback = function()
    local wk = require("which-key")
    wk.add({
      { "<leader>p", group = "python" },
      { "<leader>pi", desc = "init kernel" },
      { "<leader>pc", desc = "run cell" },
      { "<leader>pe", desc = "evaluate" },
      { "<leader>pl", desc = "eval line" },
      { "<leader>pr", desc = "re-evaluate" },
      { "<leader>po", desc = "output window" },
      { "<leader>px", desc = "interrupt kernel" },
      { "<leader>pq", desc = "deinit kernel" },
      { "<leader>pd", desc = "delete output" },
    })
  end,
})

-- Visually distinguish code / markdown / raw cell delimiters
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "quarto" },
  callback = function()
    vim.fn.matchadd("Statement", [[^# %% \[markdown\].*]])
    vim.fn.matchadd("Comment", [[^# %% \[raw\].*]])
    vim.fn.matchadd("Title", [[^# %%\( \[markdown\]\| \[raw\]\)\@!.*]])
  end,
})
