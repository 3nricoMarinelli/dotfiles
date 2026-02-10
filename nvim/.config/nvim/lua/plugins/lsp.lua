-- LSP configuration for C, C++, Python, Rust
--
-- Language servers required (install via package manager):
--   C/C++: clangd (brew install llvm)
--   Python: pyright (npm install -g pyright)
--   Rust: rust-analyzer (rustup component add rust-analyzer)
--
-- LSP Keybindings (set in on_attach):
--   gd - Go to definition
--   gD - Go to declaration
--   K - Hover documentation
--   gi - Go to implementation
--   <C-s> - Signature help
--   <leader>rn - Rename symbol
--   <leader>ca - Code action
--   gr - Find references
--   <leader>e - Show diagnostics
--   [d - Previous diagnostic
--   ]d - Next diagnostic
--   <leader>F - Format code
--
-- Autocompletion:
--   <CR> - Confirm
--   <Tab> - Next item / expand snippet
--   <S-Tab> - Previous item
--   <C-Space> - Trigger completion
--   <C-e> - Abort

local M = {}

function M.setup()
    -- Setup nvim-cmp (autocompletion)
    local cmp_status_ok, cmp = pcall(require, "cmp")
    if not cmp_status_ok then
        return
    end

    local snip_status_ok, luasnip = pcall(require, "luasnip")
    if not snip_status_ok then
        return
    end

    cmp.setup({
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        }),
        sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
        },
    })

    -- Setup LSP keymaps
    local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, opts)
    end

    -- Capabilities with cmp_nvim_lsp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local lspconfig = require('lspconfig')

    -- Python (pyright)
    lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "basic",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                }
            }
        }
    })

    -- C/C++ (clangd)
    local clangd_capabilities = capabilities
    clangd_capabilities.offsetEncoding = { "utf-16" }
    
    lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = clangd_capabilities,
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
        },
    })

    -- Rust (rust-analyzer via rust-tools)
    local rust_tools_ok, rust_tools = pcall(require, "rust-tools")
    if rust_tools_ok then
        rust_tools.setup({
            server = {
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = {
                            command = "clippy",
                        },
                        cargo = {
                            allFeatures = true,
                        },
                    }
                }
            },
        })
    else
        -- Fallback to basic rust-analyzer
        lspconfig.rust_analyzer.setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end

    -- CMake
    local cmake_ok, cmake = pcall(require, "cmake-tools")
    if cmake_ok then
        cmake.setup({
            cmake_command = "cmake",
            cmake_build_directory = "build",
            cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
            cmake_build_options = {},
            cmake_console_size = 10,
            cmake_show_console = "always",
        })
    end

    -- Crates.nvim for Rust dependency management
    local crates_ok, crates = pcall(require, "crates")
    if crates_ok then
        crates.setup()
    end

    -- Clangd extensions
    local clangd_ext_ok, clangd_ext = pcall(require, "clangd_extensions")
    if clangd_ext_ok then
        clangd_ext.setup()
    end
end

return M
