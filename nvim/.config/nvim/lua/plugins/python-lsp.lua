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
-- LSP Keybindings:
--   gd            - Go to definition      K  - Hover docs
--   gk            - Signature help        gR - LSP references (Telescope)
--   gi            - Implementations       gt - Type definitions
--   <leader>r     - Rename symbol         ga - Code actions
--   <leader>ld    - Diagnostics (Telescope)
--   [d / ]d       - Navigate diagnostics
--
-- Python-specific:
--   <leader>ba    - Add breakpoint() at current line
--   <leader>bd    - Delete all breakpoint() lines

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
    local opts = { buffer = bufnr, noremap = true, silent = true }

    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition,          vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set("n", "K",  vim.lsp.buf.hover,               vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help,      vim.tbl_extend("force", opts, { desc = "Signature help" }))
    vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration,         vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
    vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
    vim.keymap.set("n", "<leader>r",  vim.lsp.buf.rename,      vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,        vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next,        vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

    -- Telescope-powered LSP navigation
    vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>",        vim.tbl_extend("force", opts, { desc = "LSP references" }))
    vim.keymap.set("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>",   vim.tbl_extend("force", opts, { desc = "LSP implementations" }))
    vim.keymap.set("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<CR>",  vim.tbl_extend("force", opts, { desc = "LSP type definitions" }))
    vim.keymap.set("n", "<leader>lx", "<cmd>Telescope diagnostics<CR>",   vim.tbl_extend("force", opts, { desc = "LSP diagnostics" }))

    -- Python-specific: breakpoint management
    vim.keymap.set("n", "<leader>ba", "obreakpoint()<esc>",               vim.tbl_extend("force", opts, { desc = "Add breakpoint()" }))
    vim.keymap.set("n", "<leader>bd", ":g/^\\s*breakpoint()$/d<cr>",      vim.tbl_extend("force", opts, { desc = "Delete all breakpoints" }))
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
    require("config.diagnostics").apply("lsp_verbose")

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
