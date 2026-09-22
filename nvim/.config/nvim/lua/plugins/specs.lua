-- Central lazy.nvim plugin specs.
-- Batch 1: backend migration from vim-plug to lazy.nvim with behavior parity.

return {
  -- Colors / theme
  {
    "ellisonleao/gruvbox.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    config = function()
      vim.opt.termguicolors = true
      vim.opt.background = "dark"
      require("gruvbox").setup({
        italic = { strings = false },
        invert_selection = false,
      })
      vim.cmd([[ colorscheme gruvbox ]])
    end,
  },
  -- UI
  {
    "nvim-lualine/lualine.nvim",
    event = { "VimEnter", "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.lualine")
    end,
  },
  { "nvim-tree/nvim-web-devicons" },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.which-key")
    end,
  },
  {
    "romgrk/barbar.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-tree/nvim-web-devicons", "lewis6991/gitsigns.nvim" },
    config = function()
      require("plugins.barbar")
    end,
  },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.alpha")
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    cmd = {
      "SessionLoad",
      "SessionLoadLast",
      "SessionSelect",
      "SessionStop",
      "PersistenceLoad",
      "PersistenceSelect",
      "PersistenceStop",
    },
    config = function()
      require("plugins.persistence").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter")
    end,
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("plugins.colorizer")
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("plugins.render-markdown")
    end,
  },
  {
    "vimpostor/vim-tpipeline",
    event = { "VimEnter" },
  },

  -- Navigation / files / terminal
  { "MunifTanjim/nui.nvim" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("plugins.neo-tree")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.telescope")
    end,
  },
  {
    "numToStr/FTerm.nvim",
    cmd = { "FTermToggle", "FTermOpen", "FTermClose" },
    config = function()
      require("plugins.fterm")
    end,
  },
  { "famiu/bufdelete.nvim" },

  -- Editing helpers
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("plugins.autopairs")
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("plugins.comment")
    end,
  },
  {
    "kkoomen/vim-doge",
    ft = {
      -- C/C++
      "c",
      "cpp",
      "h",
      "hpp",
      "cc",
      "cxx",
      -- Python
      "python",
      -- Lua
      "lua",
      -- Rust
      "rust",
      -- Bash/Shell
      "bash",
      "sh",
      "zsh",
    },
    config = function()
      require("plugins.vim-doge")
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.gitsigns")
    end,
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.neogit")
    end,
  },

  -- LSP / tooling
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("plugins.mason")
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_enable = false,
    },
  },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "neovim/nvim-lspconfig" },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.nvim-lint")
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      require("plugins.formatting")
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "onsails/lspkind.nvim",
    },
    config = function()
      require("plugins.cmp").setup()
    end,
  },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-nvim-lsp-signature-help" },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "onsails/lspkind.nvim" },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
  },

  -- DAP / notebooks / AI helper
  {
    "mfussenegger/nvim-dap",
    ft = { "python", "c", "cpp", "rust" },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("plugins.nvim-dap")
    end,
  },
  { "nvim-neotest/nvim-nio" },
  { "rcarriga/nvim-dap-ui" },
  { "mfussenegger/nvim-dap-python" },
  { "theHamsta/nvim-dap-virtual-text" },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      require("plugins.molten")
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      require("plugins.python")
    end,
  },

  -- Shared deps / language extras
  { "nvim-lua/plenary.nvim" },
  { "mrcjkb/rustaceanvim", ft = { "rust" } },
}
