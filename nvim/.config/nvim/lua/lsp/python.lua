local M = {}

-- Detect the active Python interpreter (respects venvs and conda envs)
local function get_python_path()
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
    return venv .. "/bin/python"
  end

  -- project-local .venv
  local local_venv = vim.fn.getcwd() .. "/.venv/bin/python"
  if vim.fn.executable(local_venv) == 1 then
    return local_venv
  end

  return vim.fn.exepath("python3") or "python3"
end

-- Find binary prioritizing local virtualenvs, Mason, and system PATH
local function find_binary(name)
  -- 1. Virtual environment / Conda
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv and vim.fn.executable(venv .. "/bin/" .. name) == 1 then
    return venv .. "/bin/" .. name
  end

  -- 2. Project local .venv
  local local_venv = vim.fn.getcwd() .. "/.venv/bin/" .. name
  if vim.fn.executable(local_venv) == 1 then
    return local_venv
  end

  -- 3. Mason installed tools
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/" .. name
  if vim.fn.executable(mason_bin) == 1 then
    return mason_bin
  end

  -- 4. System PATH
  local path = vim.fn.exepath(name)
  if path and path ~= "" then
    return path
  end

  return name
end

-- Setup Python-specific tools (keymaps, DAP with debugpy)
local function apply_python_tools(bufnr)
  -- Apply Python keymaps (includes Jupyter/Molten)
  local ok, mappings = pcall(require, "config.mappings.python")
  if ok then
    mappings.apply(bufnr)
  end

  -- Setup DAP Python adapter (debugpy)
  vim.defer_fn(function()
    if _G.dap_python_setup_done then
      return
    end

    local dap_python_ok, dap_python = pcall(require, "dap-python")
    if not dap_python_ok then
      return
    end

    pcall(function()
      local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      local venv_python = get_python_path()

      if vim.fn.executable(mason_debugpy) == 1 then
        dap_python.setup(mason_debugpy)
      elseif vim.fn.executable(venv_python) == 1 then
        dap_python.setup(venv_python)
      else
        dap_python.setup("python3")
      end
    end)

    _G.dap_python_setup_done = true
  end, 150)
end

-- Setup and register Pyrefly and Ruff LSPs
function M.setup(bufnr)
  _G.python_lsp_setup_done = true
  if bufnr then
    M.start_lsp(bufnr)
  end
end

-- Start language servers (Pyrefly + Ruff) on buffer
function M.start_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
    or vim.fn.getcwd()
  local capabilities = require("lsp").capabilities()

  -- 1. Pyrefly LSP (Type checking, symbols, autocomplete, hover)
  local pyrefly_bin = find_binary("pyrefly")
  if vim.fn.executable(pyrefly_bin) == 1 then
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "pyrefly" })
    if #clients == 0 then
      vim.lsp.start({
        name = "pyrefly",
        cmd = { pyrefly_bin, "lsp" },
        root_dir = root,
        capabilities = capabilities,
        on_attach = function(client, b)
          require("lsp").on_attach(client, b)
        end,
      }, { bufnr = bufnr })
    end
  end

  -- 2. Ruff LSP (Fast linting diagnostics & code actions)
  local ruff_bin = find_binary("ruff")
  if vim.fn.executable(ruff_bin) == 1 then
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ruff" })
    if #clients == 0 then
      vim.lsp.start({
        name = "ruff",
        cmd = { ruff_bin, "server" },
        root_dir = root,
        capabilities = capabilities,
        on_attach = function(client, b)
          require("lsp").on_attach(client, b)
        end,
      }, { bufnr = bufnr })
    end
  end

  apply_python_tools(bufnr)
end

return M
