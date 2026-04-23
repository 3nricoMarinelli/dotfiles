-- Typst LSP Configuration (using vim.lsp.config API)
-- Modern LaTeX alternative
--
-- Required: typst-lsp (cargo install typst-lsp)
-- Optional: typst (brew install typst) for compilation
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
-- Typst-specific (compilation):
--   <leader>tc  - Compile current file
--   <leader>tw  - Watch file for changes

local M = {}

-- Guard to prevent multiple setups
if _G.typst_lsp_setup_done then
    return M
end

local on_attach = function(client, bufnr)
    -- Apply unified LSP keybindings from lsp-keymaps module
    require("config.lsp-keymaps").apply(bufnr)
    
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- Typst-specific: compilation (namespaced to <leader>t*)
    vim.keymap.set("n", "<leader>tc", ":!typst compile %<CR>", opts)
    vim.keymap.set("n", "<leader>tw", ":!typst watch %<CR>", opts)
end

function M.setup()
    require("config.diagnostics").apply("lsp_clean_insert")

    local capabilities = require("config.lsp-common").capabilities()

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
