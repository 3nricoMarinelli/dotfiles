-- Python LSP Configuration
-- Uses nvim-lspconfig + Mason (mason-lspconfig) when available,
-- falls back to native vim.lsp.start (Neovim 0.11+) otherwise.
--
-- Mason auto-installs pylsp (:MasonInstall pylsp or automatic via mason.lua)
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
--   <leader>rn    - Rename symbol         ga - Code actions
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

    vim.keymap.set("n", "gd", vim.lsp.buf.definition,          vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set("n", "K",  vim.lsp.buf.hover,               vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help,      vim.tbl_extend("force", opts, { desc = "Signature help" }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration,         vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
    vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,        vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next,        vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

    -- Telescope-powered LSP navigation
    vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>",        vim.tbl_extend("force", opts, { desc = "LSP references" }))
    vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>",   vim.tbl_extend("force", opts, { desc = "LSP implementations" }))
    vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>",  vim.tbl_extend("force", opts, { desc = "LSP type definitions" }))
    vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>",   vim.tbl_extend("force", opts, { desc = "LSP diagnostics" }))
    vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>",vim.tbl_extend("force", opts, { desc = "LSP references" }))

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
    vim.diagnostic.config({
        signs            = true,
        update_in_insert = false,
        underline        = true,
        severity_sort    = true,
        virtual_text     = { spacing = 4, prefix = "●" },
    })

    local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if cmp_lsp_ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

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

    -- Try nvim-lspconfig + mason-lspconfig first (NeuralNine's approach)
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")

    if lspconfig_ok and mason_lspconfig_ok then
        -- mason-lspconfig handler: runs when mason ensures pylsp is installed
        mason_lspconfig.setup_handlers({
            ["pylsp"] = function()
                lspconfig.pylsp.setup({
                    capabilities = capabilities,
                    settings     = pylsp_settings,
                    before_init  = function(_, config)
                        -- inject detected python path into jedi so pylsp uses the right env
                        config.settings.pylsp.plugins.jedi = {
                            environment = get_python_path(),
                        }
                    end,
                })
            end,
        })
    elseif lspconfig_ok then
        -- lspconfig without mason: direct setup
        lspconfig.pylsp.setup({
            capabilities = capabilities,
            settings     = pylsp_settings,
            before_init  = function(_, config)
                config.settings.pylsp.plugins.jedi = {
                    environment = get_python_path(),
                }
            end,
        })
    else
        -- Fallback: native vim.lsp.start (Neovim 0.11+ API)
        M.lsp_config = {
            name         = "pylsp",
            cmd          = { pylsp_cmd },
            capabilities = capabilities,
            settings     = pylsp_settings,
        }
    end

    _G.python_lsp_setup_done = true
end

function M.start_lsp(bufnr)
    -- nvim-lspconfig path: server is registered but FileType already fired before setup,
    -- so lspconfig's internal autocmd missed this buffer → force start manually.
    local lspconfig_ok, _ = pcall(require, "lspconfig")
    if lspconfig_ok then
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "pylsp" })
        if #clients == 0 then
            -- LspStart is provided by nvim-lspconfig and attaches to the current buf
            vim.cmd("LspStart pylsp")
        end
        return
    end

    -- Fallback: native vim.lsp.start (only used when lspconfig is unavailable)
    if not M.lsp_config then return end

    local config     = vim.deepcopy(M.lsp_config)
    config.root_dir  = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
    config.before_init = function(_, cfg)
        cfg.settings.pylsp.plugins.jedi = { environment = get_python_path() }
    end
    vim.lsp.start(config, { bufnr = bufnr })
end

return M
