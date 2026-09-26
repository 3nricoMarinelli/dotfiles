-- Python & Jupyter notebook (.ipynb) support via Jupytext and Molten

local jupytext_ok, jupytext = pcall(require, "jupytext")
if not jupytext_ok then
  return {}
end

-- Initialize empty .ipynb files with valid JSON structure for Jupytext
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

  custom_language_formatting = {
    python = {
      extension = "py",
      style = "percent",
      force_ft = "python",
    },
  },
})

-- Walk parent directories to find the nearest virtualenv root (.venv)
local function find_venv_root()
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv then
    return venv
  end

  local path = vim.fn.expand("%:p:h")
  while path ~= "/" and path ~= "" do
    if vim.fn.isdirectory(path .. "/.venv") == 1 then
      return path .. "/.venv"
    end
    path = vim.fn.fnamemodify(path, ":h")
  end
  return nil
end

-- Register or attach the Jupyter kernel (background ipykernel)
local function init_venv_kernel()
  local root = find_venv_root()
  if not root then
    vim.notify("Molten: No virtual environment detected, opening kernel picker...", vim.log.levels.INFO)
    local ok, _ = pcall(vim.cmd, "MoltenInit")
    if not ok then
      vim.notify("MoltenInit command not available. Run :UpdateRemotePlugins and restart Neovim.", vim.log.levels.ERROR)
    end
    return
  end

  local kernel_name = vim.fn.fnamemodify(root == os.getenv("VIRTUAL_ENV") and root or vim.fn.fnamemodify(root, ":h"), ":t")
  local python_bin = root .. "/bin/python"
  if vim.fn.executable(python_bin) ~= 1 then
    python_bin = root .. "/python"
  end

  -- Attempt to register ipykernel for this environment
  if vim.fn.executable(python_bin) == 1 then
    local register_cmd = string.format("%s -m ipykernel install --user --name %s --display-name %s",
      vim.fn.shellescape(python_bin),
      vim.fn.shellescape(kernel_name),
      vim.fn.shellescape(kernel_name)
    )
    vim.fn.system(register_cmd)
  end

  local ok_init, _ = pcall(vim.cmd, "MoltenInit " .. kernel_name)
  if not ok_init then
    -- Try fallback to default MoltenInit
    local ok_fallback, _ = pcall(vim.cmd, "MoltenInit")
    if not ok_fallback then
      vim.notify("MoltenInit failed. Ensure pynvim & jupyter_client are installed.", vim.log.levels.ERROR)
    end
  else
    vim.notify("Attached background kernel: " .. kernel_name, vim.log.levels.INFO)
  end
end

-- Get start and end lines for the cell under cursor
local function get_cell_range()
  local line = vim.fn.line(".")
  local total = vim.fn.line("$")

  local start_line = 1
  for i = line, 1, -1 do
    if vim.fn.getline(i):match("^# %%") then
      start_line = (i == line) and line or (i + 1)
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

  return start_line, end_line
end

-- Run the cell under cursor
local function run_current_cell()
  local start_line, end_line = get_cell_range()
  if start_line > end_line then
    return
  end
  vim.fn.MoltenEvaluateRange(start_line, end_line)
end

-- Run cell and advance cursor to next cell (Shift-Enter behavior in Zed & Jupyter)
local function run_current_cell_and_advance()
  run_current_cell()

  local line = vim.fn.line(".")
  local total = vim.fn.line("$")

  for i = line + 1, total do
    if vim.fn.getline(i):match("^# %%") then
      -- Jump to the first non-empty line of the next cell
      local next_line = i + 1
      while next_line <= total and vim.fn.getline(next_line):match("^%s*$") do
        next_line = next_line + 1
      end
      vim.api.nvim_win_set_cursor(0, { math.min(next_line, total), 0 })
      return
    end
  end
end

-- Run all cells in current buffer
local function run_all_cells()
  local total = vim.fn.line("$")
  vim.fn.MoltenEvaluateRange(1, total)
end

-- Visually distinguish cell markers in Python / Quarto
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
  run_current_cell_and_advance = run_current_cell_and_advance,
  run_all_cells = run_all_cells,
}
