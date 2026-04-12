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
-- LSP Keybindings (unified across all languages, see lsp-keymaps.lua):
--   <leader>ld  - Go to definition
--   K           - Hover documentation
--   <leader>lk  - Signature help
--   <leader>r   - Rename symbol
--   <leader>la  - Code actions
--   <leader>li  - Implementations
--   <leader>lt  - Type definitions
--   <leader>lD  - Declarations
--   <leader>lr  - References
--   <leader>lx  - Diagnostics (Telescope)
--   [d / ]d     - Navigate diagnostics

local M = {}

-- Guard to prevent multiple setups
if _G.c_cpp_lsp_setup_done then
    return M
end

local on_attach = function(client, bufnr)
    -- Apply unified LSP keybindings from lsp-keymaps module
    require("config.lsp-keymaps").apply(bufnr)
end

function M.setup()
    -- Use clean-insert profile: verbose in normal mode, clean while typing
    require("config.diagnostics").apply("lsp_clean_insert")

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
