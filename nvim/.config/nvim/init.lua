-- bread's neovim config (with cacharle's C/C++ enhancements)
-- keymaps are in lua/config/mappings.lua
-- install a patched font & ensure your terminal supports glyphs
-- enjoy :D

vim.g.start_time = vim.fn.reltime()
vim.loader.enable() --  SPEEEEEEEEEEED 

-- Plugin manager backend: lazy.nvim
require("core.lazy")

-- move config and plugin config to alternate files
require("config.theme")
require("config.health-compat")
require("config.keymap-helper") -- helper for vim.keymap + which-key registration
require("config.mappings")
require("config.options")
require("config.autocmd")
require("config.lint-toggle")

-- lazy.nvim specs now own plugin setup; keep runtime-only modules here.
-- bufdelete: smart buffer deletion
pcall(require, "bufdelete")

-- Lazy load LSP per language (cacharle's approach)
-- Setup on first FileType event, then start LSP immediately
local c_cpp_lsp_loaded = false
local cmake_loaded = false
local gtest_loaded = false
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(args)
        if not c_cpp_lsp_loaded then
            require("plugins.c-cpp-lsp").setup()
            c_cpp_lsp_loaded = true
        end
        -- Start LSP for this buffer
        require("plugins.c-cpp-lsp").start_lsp(args.buf)

        -- Load CMake and GTest on first C/C++ file
        if not cmake_loaded then
            require("plugins.cmake").setup()
            cmake_loaded = true
        end
        if not gtest_loaded then
            require("plugins.gtest").setup()
            gtest_loaded = true
        end
    end,
})

local python_lsp_loaded = false
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
        -- Only for actual .py files, not for filetypes set on buffers without an extension
        local ext = vim.fn.expand("%:e")
        if ext ~= "py" and ext ~= "" and ext ~= "ipynb" then return end

        if not python_lsp_loaded then
            require("plugins.python-lsp").setup()
            python_lsp_loaded = true
        end
        require("plugins.python-lsp").start_lsp(args.buf)
    end,
})


local rust_lsp_loaded = false
vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function(args)
        if not rust_lsp_loaded then
            require("plugins.rust-lsp").setup()
            rust_lsp_loaded = true
        end
        -- rustaceanvim handles LSP automatically
    end,
})

local typst_lsp_loaded = false
vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function(args)
        if not typst_lsp_loaded then
            require("plugins.typst-lsp").setup()
            typst_lsp_loaded = true
        end
        require("plugins.typst-lsp").start_lsp(args.buf)
    end,
})

load_theme()
