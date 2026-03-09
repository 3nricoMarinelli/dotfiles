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
--     - Auto-detect C++ stdlib headers (/usr/include/c++/*)
--     - compile-on-save script in ~/dotfiles/scripts/
--   LSP Keys: gd, K, <leader>r, <leader>q, [d, ]d
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
Plug('NeogitOrg/neogit') --git interface (replaces git-conflict)
Plug('sindrets/diffview.nvim') --git diff view (works with neogit)
Plug('numToStr/Comment.nvim') --easier comments
Plug('brenoprata10/nvim-highlight-colors') --color highlight (modern replacement for nvim-colorizer)
Plug('ibhagwan/fzf-lua') --fuzzy finder and grep
Plug('numToStr/FTerm.nvim') --floating terminal
Plug('MeanderingProgrammer/render-markdown.nvim') --render md inline
Plug('emmanueltouzery/decisive.nvim') --view csv files

-- Mason: LSP/tool environment management (:Mason for UI)
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')       -- bridges Mason ↔ nvim-lspconfig
Plug('WhoIsSethDaniel/mason-tool-installer.nvim') -- auto-installs linters/DAP adapters

-- nvim-lspconfig: used by mason-lspconfig for Python LSP (pylsp)
Plug('neovim/nvim-lspconfig')

-- Python DAP debugging
Plug('mfussenegger/nvim-dap')
Plug('nvim-neotest/nvim-nio')                   -- required by nvim-dap-ui
Plug('rcarriga/nvim-dap-ui')
Plug('mfussenegger/nvim-dap-python')            -- Python debug adapter integration
Plug('theHamsta/nvim-dap-virtual-text')         -- variable values as virtual text

-- Python notebook support
Plug('benlubas/molten-nvim')                    -- Jupyter kernel: pip install pynvim jupyter_client
Plug('GCBallesteros/jupytext.nvim')             -- .ipynb ↔ .py (pip install jupytext)

-- Language support plugins (lazy loaded)
-- NOTE: Using vim.lsp.config (Neovim 0.11+) - no need for nvim-lspconfig plugin
Plug('hrsh7th/nvim-cmp') --autocompletion
Plug('hrsh7th/cmp-nvim-lsp') --LSP source for nvim-cmp
Plug('hrsh7th/cmp-buffer') --buffer completions
Plug('hrsh7th/cmp-path') --path completions
Plug('hrsh7th/cmp-nvim-lsp-signature-help') --signature help
Plug('onsails/lspkind.nvim') --LSP kind icons
Plug('nvim-lua/plenary.nvim') --required for some plugins
Plug('mrcjkb/rustaceanvim', { ['for'] = 'rust' })
Plug('kaarmu/typst.vim', { ['for'] = { 'typst' } }) --syntax & filetype detection
Plug('cdelledonne/vim-cmake', { ['for'] = { 'c', 'cpp', 'cmake' } }) --CMake integration
Plug('antoinemadec/FixCursorHold.nvim') --required for vim-cmake in neovim
Plug('alepez/vim-gtest', { ['for'] = { 'c', 'cpp' } }) --GoogleTest integration

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
require("plugins.neogit")
require("plugins.lualine")
require("plugins.mason")           -- must load before python-lsp (adds Mason bin to PATH)
require("plugins.cmp") --autocompletion (lazy loaded on InsertEnter)
require("plugins.nvim-lint")
-- require("plugins.nvim-tree")
require("plugins.render-markdown")
-- require("plugins.treesitter")
-- require("plugins.which-key")
require("plugins.molten")
require("plugins.ipynb")    -- must load at startup so jupytext BufReadCmd is registered before any .ipynb open

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
local python_dap_loaded = false
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

        -- Load DAP on first Python file (deferred so it doesn't slow startup)
        if not python_dap_loaded then
            vim.defer_fn(function()
                require("plugins.nvim-dap")
            end, 50)
            python_dap_loaded = true
        end
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
