-- python.lua: Python & Jupyter notebook support
-- Handles: .py files, .ipynb files (via Jupytext), and Quarto notebooks
-- Features: LSP, DAP, Molten REPL, cell execution, which-key docs
--
-- Requires: pip install jupytext pynvim jupyter_client
-- Usage: Open any .py, .ipynb, or .qmd file with # %% cells

-- Jupytext: transparent .ipynb ↔ Python conversion
local jupytext_ok, jupytext = pcall(require, "jupytext")
if not jupytext_ok then
  return
end

-- Ensure newly created or empty .ipynb files have minimal valid notebook JSON
-- so Jupytext can initialize them without crashing.
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "*.ipynb",
  callback = function(ev)
    local path = vim.fn.resolve(vim.fn.expand(ev.match))
    local f = io.open(path, "r")
    local is_empty = true
    if f then
      local c = f:read("*a")
      f:close()
      if c and #vim.trim(c) > 0 then
        is_empty = false
      end
    end
    if is_empty then
      local out = io.open(path, "w")
      if out then
        out:write(vim.json.encode({
          cells = {},
          metadata = {
            kernelspec = {
              display_name = "Python 3",
              language = "python",
              name = "python3",
            },
            language_info = {
              name = "python",
            },
          },
          nbformat = 4,
          nbformat_minor = 2,
        }))
        out:close()
      end
    end
  end,
})

jupytext.setup({
  style = "percent", -- use # %% cell markers (Jupyter percent format)
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
    local ok, err = pcall(vim.cmd, "MoltenInit")
    if not ok then
      vim.notify("MoltenInit command not found. Try running :UpdateRemotePlugins and restarting.", vim.log.levels.ERROR)
    end
    return
  end

  local name = vim.fn.fnamemodify(root, ":t")
  -- Uses uv to ensure ipykernel is installed and the kernel is registered
  local cmd = string.format("cd %s && uv run --with ipykernel python -m ipykernel install --user --name %s", 
                               vim.fn.shellescape(root), 
                               vim.fn.shellescape(name))
  
  local ok = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("molten: kernel registration failed:\n" .. ok, vim.log.levels.ERROR)
    return
  end

  local ok_init, err_init = pcall(vim.cmd, "MoltenInit " .. name)
  if not ok_init then
    vim.notify("MoltenInit command not found. Try running :UpdateRemotePlugins and restarting.", vim.log.levels.ERROR)
  end
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

  vim.fn.MoltenEvaluateRange(start_line, end_line)
end

-- Visually distinguish code / markdown / raw cell delimiters
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "quarto" },
  callback = function()
    vim.fn.matchadd("Statement", [[^# %% \[markdown\].*]])
    vim.fn.matchadd("Comment", [[^# %% \[raw\].*]])
    vim.fn.matchadd("Title", [[^# %%\( \[markdown\]\| \[raw\]\)\@!.*]])
  end,
})

return {
  init_venv_kernel = init_venv_kernel,
  run_current_cell = run_current_cell,
}
