-- Typst LSP Configuration (using vim.lsp.config API)
-- Modern LaTeX alternative
--
-- Required: typst-lsp (cargo install typst-lsp)
-- Optional: typst (brew install typst) for compilation
--
-- LSP Keybindings (same as other languages):
--   gd - Go to definition
--   K - Hover docs
--   <leader>rn - Rename
--   [d / ]d - Navigate diagnostics

local M = {}

-- Guard to prevent multiple setups
if _G.typst_lsp_setup_done then
    return M
end

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    
    local has_telescope = pcall(require, "telescope")
    if has_telescope then
        vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>", opts)
        vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)
    else
        vim.keymap.set("n", "<leader>ld", vim.diagnostic.setloclist, opts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
    end
    
    -- Typst-specific: compile on save
    vim.keymap.set("n", "<leader>tc", ":!typst compile %<CR>", opts)
    vim.keymap.set("n", "<leader>tw", ":!typst watch %<CR>", opts)
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
        name = "typst-lsp",
        cmd = { "typst-lsp" },
        root_dir = vim.fs.root(0, { ".git" }),
        capabilities = capabilities,
        settings = {
            exportPdf = "onSave", -- Auto-export PDF on save
        },
    }
    
    -- Set up LspAttach autocmd for keybindings
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(attach_args)
            local client = vim.lsp.get_client_by_id(attach_args.data.client_id)
            if client and client.name == "typst-lsp" then
                on_attach(client, attach_args.buf)
            end
        end,
    })
    
    _G.typst_lsp_setup_done = true
end

function M.start_lsp(bufnr)
    if not M.lsp_config then
        vim.notify("Typst LSP not configured, run setup() first", vim.log.levels.ERROR)
        return
    end
    
    local config = vim.deepcopy(M.lsp_config)
    config.root_dir = vim.fs.root(bufnr, { ".git" })
    vim.lsp.start(config, { bufnr = bufnr })
end

return M
