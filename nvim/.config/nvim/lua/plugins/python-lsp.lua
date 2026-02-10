-- Python LSP Configuration (using vim.lsp.config API - Neovim 0.11+)
--
-- Required: python-lsp-server (pip install 'python-lsp-server[all]' pyls-flake8)
--
-- LSP Keybindings (same as C/C++):
--   gd - Go to definition
--   K - Hover docs
--   <leader>rn - Rename
--   [d / ]d - Navigate diagnostics
--
-- Python-specific:
--   <leader>ba - Add breakpoint()
--   <leader>bd - Delete all breakpoint() lines

local M = {}

-- Guard to prevent multiple setups
if _G.python_lsp_setup_done then
    return M
end

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- Navigation
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)  -- Go to definition
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)         -- Hover documentation
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)  -- Signature help
    
    -- Diagnostics navigation
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)  -- Previous diagnostic
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)  -- Next diagnostic
    
    -- Refactoring
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)  -- Rename symbol
    
    -- Telescope integrations
    local has_telescope = pcall(require, "telescope")
    if has_telescope then
        vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>", opts)  -- List diagnostics
        vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)  -- List references
    else
        vim.keymap.set("n", "<leader>ld", vim.diagnostic.setloclist, opts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
    end
    
    -- Python-specific: breakpoint management
    vim.keymap.set("n", "<leader>ba", "obreakpoint()<esc>", opts)  -- Add breakpoint
    vim.keymap.set("n", "<leader>bd", ":g/^\\s*breakpoint()$/d<cr>", opts)  -- Delete all breakpoints
end

function M.setup()
    vim.diagnostic.config({ signs = false, update_in_insert = false })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_lsp_ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Store config for later use
    M.lsp_config = {
        name = "pylsp",
        cmd = { "pylsp" },
        root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }),
        capabilities = capabilities,
        settings = {
            pylsp = {
                plugins = {
                    flake8 = {
                        enabled = true,
                        ignore = {"E501", "E221", "W503", "E241", "E402"},
                        maxLineLength = 100,
                    },
                    pycodestyle = {
                        enabled = false,
                    },
                    pylint = {
                        enabled = false,
                    },
                },
            },
        },
    }
    
    -- Set up LspAttach autocmd for keybindings
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(attach_args)
            local client = vim.lsp.get_client_by_id(attach_args.data.client_id)
            if client and client.name == "pylsp" then
                on_attach(client, attach_args.buf)
            end
        end,
    })
    
    _G.python_lsp_setup_done = true
end

function M.start_lsp(bufnr)
    if not M.lsp_config then
        vim.notify("Python LSP not configured, run setup() first", vim.log.levels.ERROR)
        return
    end
    
    local config = vim.deepcopy(M.lsp_config)
    config.root_dir = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
    vim.lsp.start(config, { bufnr = bufnr })
end

return M
