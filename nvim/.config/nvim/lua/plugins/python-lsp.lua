-- Python LSP Configuration
-- Uses native vim.lsp.config (Neovim 0.11+ API).
-- Mason is used only for installation (:MasonInstall pylsp).
-- Required manually if not using Mason:
--   pip install 'python-lsp-server[all]' python-lsp-isort
--
-- pylsp plugins enabled:
--   pyflakes      - undefined names, unused imports
--   pycodestyle   - PEP8 style (maxLineLength 100)
--   mccabe        - cyclomatic complexity
--   rope          - completions + refactoring (rename, extract)
--   isort         - import sorting (requires python-lsp-isort)
--   pylint        - disabled (use ruff via nvim-lint instead)
--
-- LSP Keybindings (unified, see lsp-keymaps.lua):
--   <leader>ld / <leader>]  - Go to definition
--   K                        - Hover documentation
--   <leader>lk / gk         - Signature help
--   <leader>r / <leader>rn  - Rename symbol
--   <leader>la              - Code actions
--   <leader>li              - Implementations
--   <leader>lt              - Type definitions
--   <leader>lD / <leader>[  - Declarations
--   <leader>lr              - References
--   <leader>lx / <leader>q  - Diagnostics (Telescope)
--   <leader>p               - Workspace symbols (Telescope)
--   [d / ]d                 - Navigate diagnostics
--
-- Python-specific (breakpoint management):
--   <leader>pb  - Add breakpoint() at current line
--   <leader>pB  - Delete all breakpoint() lines

local M = {}

-- Guard to prevent multiple setups
if _G.python_lsp_setup_done then
    return M
end

-- Detect the active Python interpreter (respects venvs and conda envs)
local function get_python_path()
    local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
    if venv then return venv .. "/bin/python" end

    -- project-local .venv
    local local_venv = vim.fn.getcwd() .. "/.venv/bin/python"
    if vim.fn.executable(local_venv) == 1 then return local_venv end

    return vim.fn.exepath("python3") or "python3"
end

-- Keybindings attached when pylsp connects to a buffer
local function on_attach(client, bufnr)
    -- Apply unified LSP keybindings from lsp-keymaps module
    require("config.lsp-keymaps").apply(bufnr)
    
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- Python-specific: breakpoint management (namespaced to <leader>p*)
    -- Note: <leader>p is already mapped to workspace symbols via lsp-keymaps
    -- Using <leader>pb / <leader>pB for breakpoint operations
    vim.keymap.set("n", "<leader>pb", "obreakpoint()<esc>", opts)
    vim.keymap.set("n", "<leader>pB", ":g/^\\s*breakpoint()$/d<cr>", opts)
end

-- Shared pylsp settings (NeuralNine-style: more plugins enabled)
local pylsp_settings = {
    pylsp = {
        plugins = {
            pyflakes     = { enabled = true },
            pycodestyle  = { enabled = true, maxLineLength = 100, ignore = { "E501", "W503" } },
            mccabe       = { enabled = true, threshold = 15 },
            rope_completion = { enabled = true },
            rope_autoimport = { enabled = true },
            -- isort via python-lsp-isort plugin
            isort        = { enabled = true },
            -- disable: we use ruff via nvim-lint instead
            pylint       = { enabled = false },
            flake8       = { enabled = false },
            ruff         = { enabled = false },
        },
    },
}

function M.setup()
    require("config.diagnostics").apply("lsp_clean_insert")

    local capabilities = require("config.lsp-common").capabilities()

    -- Register keybindings via LspAttach (fires for pylsp only)
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("PythonLspAttach", { clear = false }),
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client.name == "pylsp" then
                on_attach(client, ev.buf)
            end
        end,
    })

    -- Path to use: prefer the virtualenv's pylsp if present
    local pylsp_cmd = "pylsp"
    local venv_pylsp = vim.fn.getcwd() .. "/.venv/bin/pylsp"
    if vim.fn.executable(venv_pylsp) == 1 then
        pylsp_cmd = venv_pylsp
    end

    -- Inject jedi environment into a copy of pylsp_settings
    local settings = vim.deepcopy(pylsp_settings)
    settings.pylsp.plugins.jedi = { environment = get_python_path() }

    -- Native vim.lsp.config (Neovim 0.11+ API)
    vim.lsp.config("pylsp", {
        cmd          = { pylsp_cmd },
        filetypes    = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        capabilities = capabilities,
        settings     = settings,
    })
    vim.lsp.enable("pylsp")

    _G.python_lsp_setup_done = true
end

function M.start_lsp(bufnr)
    -- vim.lsp.enable registers an autocmd that fires on FileType, but since setup()
    -- is called lazily (on first FileType python), the current buffer may have been
    -- missed. Manually start if no client is attached yet.
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "pylsp" })
    if #clients == 0 then
        local settings = vim.deepcopy(pylsp_settings)
        settings.pylsp.plugins.jedi = { environment = get_python_path() }
        vim.lsp.start({
            name         = "pylsp",
            cmd          = { "pylsp" },
            root_dir     = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }),
            capabilities = require("config.lsp-common").capabilities(),
            settings     = settings,
        }, { bufnr = bufnr })
    end
end

return M
