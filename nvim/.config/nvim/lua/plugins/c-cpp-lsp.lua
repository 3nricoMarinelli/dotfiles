-- C/C++ LSP Configuration (using vim.lsp.config API - Neovim 0.11+)
-- Superior clangd setup with clang-tidy for real-time linting
--
-- Required: clangd (brew install llvm)
-- Optional: .clang-tidy file in project root for custom rules
--
-- Linting:
--   - clang-tidy (via clangd) - real-time as you type
--   - cppcheck (via nvim-lint) - on save (see nvim-lint.lua)
--
-- LSP Keybindings:
--   gd - Go to definition
--   K - Hover docs
--   gk - Signature help
--   <leader>r - Rename symbol
--   <leader>ld - LSP diagnostics
--   <leader>ls - LSP workspace symbols
--   <leader>lr - LSP references
--   [d / ]d - Navigate diagnostics

local M = {}

-- Guard to prevent multiple setups
if _G.c_cpp_lsp_setup_done then
    return M
end

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- Navigation
    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)  -- Go to definition
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)         -- Hover documentation
    vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help, opts)  -- Signature help
    
    -- Diagnostics navigation
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)  -- Previous diagnostic
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)  -- Next diagnostic
    
    -- Refactoring
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)  -- Rename symbol
    
    -- Telescope integrations (fallback to builtin if telescope not available)
    local has_telescope = pcall(require, "telescope")
    if has_telescope then
        vim.keymap.set("n", "<leader>lx", "<cmd>Telescope diagnostics<CR>", opts)  -- List diagnostics
        vim.keymap.set("n", "<leader>ls", "<cmd>Telescope lsp_workspace_symbols<CR>", opts)  -- List symbols
        vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)  -- List references
    else
        vim.keymap.set("n", "<leader>lx", vim.diagnostic.setloclist, opts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
    end
end

function M.setup()
    -- Show signs and update diagnostics as you type (VSCode-like)
    require("config.diagnostics").apply("lsp_verbose")

    -- Get capabilities for autocompletion
    local capabilities = require("config.lsp-common").capabilities()

    -- Store config for later use
    M.lsp_config = {
        name = "clangd",
        cmd = {
            "clangd",
            "--background-index",        -- index in background
            "--clang-tidy",              -- Enable clang-tidy checks!
            "--header-insertion=iwyu",   -- Include what you use
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--pch-storage=memory",      -- store precompiled headers in memory
        },
        root_dir = vim.fs.root(0, { ".clangd", "compile_commands.json", ".git" }),
        capabilities = capabilities,
    }
    
    -- Set up LspAttach autocmd for keybindings
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(attach_args)
            local client = vim.lsp.get_client_by_id(attach_args.data.client_id)
            if client and client.name == "clangd" then
                on_attach(client, attach_args.buf)
            end
        end,
    })
    
    _G.c_cpp_lsp_setup_done = true
end

function M.start_lsp(bufnr)
    if not M.lsp_config then
        vim.notify("C/C++ LSP not configured, run setup() first", vim.log.levels.ERROR)
        return
    end
    
    -- Use vim.lsp.start for reliable LSP starting
    local config = vim.deepcopy(M.lsp_config)
    config.root_dir = vim.fs.root(bufnr, { ".clangd", "compile_commands.json", ".git" })
    vim.lsp.start(config, { bufnr = bufnr })
end

return M
