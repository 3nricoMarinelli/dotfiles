-- bread's neovim config (with cacharle's C/C++ enhancements)
-- keymaps are in lua/config/mappings.lua
-- install a patched font & ensure your terminal supports glyphs
-- enjoy :D
--
-- C/C++/Python/Rust Language Support (inspired by cacharle/dotfiles):
--   LSP using vim.lsp.config (Neovim 0.11+ built-in API):
--     - clangd for C/C++ (header-insertion=never, pch-storage=memory, malloc-trim)
--     - pylsp for Python (with flake8 linting)
--     - rust-analyzer via rustaceanvim for Rust
--   Utilities:
--     - ArgWrap: <leader>aw to toggle multi-line function args
--     - EasyAlign: ga for alignment
--     - Auto-detect C++ stdlib headers (/usr/include/c++/*)
--     - compile-on-save script in ~/dotfiles/scripts/
--   LSP Keys: gd, K, <leader>rn, <leader>q, <leader>r, [d, ]d
--   Install: brew install llvm && pip install 'python-lsp-server[all]' pyls-flake8
--   Note: No nvim-lspconfig plugin needed - using native vim.lsp.config!

-- auto install vim-plug and plugins, if not found
local data_dir = vim.fn.stdpath('data')
if vim.fn.empty(vim.fn.glob(data_dir .. '/site/autoload/plug.vim')) == 1 then
	vim.cmd('silent !curl -fLo ' .. data_dir .. '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
	vim.o.runtimepath = vim.o.runtimepath
	vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

local vim = vim
local Plug = vim.fn['plug#']

vim.g.start_time = vim.fn.reltime()
vim.loader.enable() --  SPEEEEEEEEEEED 
vim.call('plug#begin')

Plug('catppuccin/nvim', { ['as'] = 'catppuccin' }) --colorscheme
Plug('ellisonleao/gruvbox.nvim', { ['as'] = 'gruvbox' }) --colorscheme 2
Plug('uZer/pywal16.nvim', { [ 'as' ] = 'pywal16' }) --or, pywal colorscheme
Plug('nvim-lualine/lualine.nvim') --statusline
Plug('nvim-tree/nvim-web-devicons') --pretty icons
Plug('echasnovski/mini.icons') --icons for which-key
Plug('folke/which-key.nvim') --mappings popup
Plug('romgrk/barbar.nvim') --bufferline
Plug('goolord/alpha-nvim') --pretty startup
Plug('nvim-treesitter/nvim-treesitter') --improved syntax
Plug('mfussenegger/nvim-lint') --async linter
Plug('nvim-tree/nvim-tree.lua') --file explorer
Plug('windwp/nvim-autopairs') --autopairs 
Plug('lewis6991/gitsigns.nvim') --git
Plug('numToStr/Comment.nvim') --easier comments
Plug('brenoprata10/nvim-highlight-colors') --color highlight (modern replacement for nvim-colorizer)
Plug('ibhagwan/fzf-lua') --fuzzy finder and grep
Plug('numToStr/FTerm.nvim') --floating terminal
Plug('ron-rs/ron.vim') --ron syntax highlighting
Plug('MeanderingProgrammer/render-markdown.nvim') --render md inline
Plug('emmanueltouzery/decisive.nvim') --view csv files
Plug('folke/twilight.nvim') --surrounding dim

-- Language support plugins (lazy loaded)
-- NOTE: Using vim.lsp.config (Neovim 0.11+) - no need for nvim-lspconfig plugin
Plug('hrsh7th/nvim-cmp') --autocompletion
Plug('hrsh7th/cmp-nvim-lsp') --LSP source for nvim-cmp
Plug('hrsh7th/cmp-buffer') --buffer completions
Plug('hrsh7th/cmp-path') --path completions
Plug('hrsh7th/cmp-nvim-lsp-signature-help') --signature help
Plug('onsails/lspkind.nvim') --LSP kind icons
Plug('nvim-lua/plenary.nvim') --required for some plugins

-- Rust-specific (lazy loaded, uses rustaceanvim instead of rust-tools)
Plug('mrcjkb/rustaceanvim', { ['for'] = 'rust' })

-- Typst support (modern LaTeX alternative)
Plug('kaarmu/typst.vim', { ['for'] = 'typst' }) --syntax & filetype detection

-- C/C++-specific utilities from cacharle's config
Plug('FooSoft/vim-argwrap') --multi-line function arguments
Plug('junegunn/vim-easy-align') --alignment tool

-- Optional: Telescope for better LSP UX
Plug('nvim-telescope/telescope.nvim')

vim.call('plug#end')

-- move config and plugin config to alternate files
require("config.theme")
require("config.mappings")
require("config.options")
require("config.autocmd")

require("plugins.alpha")
-- require("plugins.autopairs")
require("plugins.barbar")
-- require("plugins.colorizer")
require("plugins.colorscheme")
require("plugins.comment")
-- require("plugins.fterm")
-- require("plugins.fzf-lua")
require("plugins.gitsigns")
require("plugins.lualine")
require("plugins.cmp") --autocompletion (lazy loaded on InsertEnter)
require("plugins.nvim-lint")
-- require("plugins.nvim-tree")
require("plugins.render-markdown")
-- require("plugins.treesitter")
-- require("plugins.which-key")

vim.defer_fn(function() 
		--defer non-essential configs,
		--purely for experimental purposes:
		--this only makes a difference of +-10ms on initial startup
require("plugins.autopairs")
require("plugins.colorizer")
require("plugins.fterm")
require("plugins.fzf-lua")
require("plugins.nvim-tree")
require("plugins.treesitter")
require("plugins.which-key")
end, 100)

-- Lazy load LSP per language (cacharle's approach)
-- Setup on first FileType event, then start LSP immediately
local c_cpp_lsp_loaded = false
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(args)
        if not c_cpp_lsp_loaded then
            require("plugins.c-cpp-lsp").setup()
            c_cpp_lsp_loaded = true
        end
        -- Start LSP for this buffer
        require("plugins.c-cpp-lsp").start_lsp(args.buf)
    end,
})

local python_lsp_loaded = false
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
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
