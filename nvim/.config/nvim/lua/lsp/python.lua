local M = {}

-- Detect the active Python interpreter (respects venvs and conda envs)
local function get_python_path()
    local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
    if venv then
        return venv .. "/bin/python"
    end

    -- project-local .venv
    local local_venv = vim.fn.getcwd() .. "/.venv/bin/python"
    if vim.fn.executable(local_venv) == 1 then
        return local_venv
    end

    return vim.fn.exepath("python3") or "python3"
end

-- Setup Python-specific tools (keymaps, DAP)
local function apply_python_tools(bufnr)
    -- Apply Python keymaps (includes Jupyter/Molten)
    local ok, mappings = pcall(require, "config.mappings.python")
    if ok then
        mappings.apply(bufnr)
    end

    -- Setup DAP Python adapter (deferred to ensure dap.adapters exists)
    vim.defer_fn(function()
        if _G.dap_python_setup_done then
            return -- Already set up
        end

        local dap_python_ok, dap_python = pcall(require, "dap-python")
        if not dap_python_ok then
            return -- dap-python not available
        end

        -- Try to set up Python adapter; gracefully handle if dap.adapters isn't ready
        local ok, err = pcall(function()
            local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            if vim.fn.executable(mason_debugpy) == 1 then
                dap_python.setup(mason_debugpy)
            else
                dap_python.setup("python3")
            end
        end)

        if ok then
            _G.dap_python_setup_done = true
        end
    end, 200)
end

-- Configure pyrefly as the Python LSP
function M.setup(bufnr)
    -- Configure pyrefly
    local pyrefly_cmd = "pyrefly"
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if vim.fn.executable(mason_bin .. "/pyrefly") == 1 then
        pyrefly_cmd = mason_bin .. "/pyrefly"
    end

    vim.lsp.config("pyrefly", {
        cmd = { pyrefly_cmd, "lsp" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        capabilities = require("lsp").capabilities(),
    })
    vim.lsp.enable("pyrefly")
    _G.python_lsp_setup_done = true

    -- If a buffer is provided, apply tools immediately
    if bufnr then
        apply_python_tools(bufnr)
    end
end

-- Dummy function to prevent errors in hooks.lua
function M.start_lsp(bufnr)
end

return M
