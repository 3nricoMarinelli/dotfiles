-- Central lazy.nvim plugin specs.
-- Batch 1: backend migration from vim-plug to lazy.nvim with behavior parity.

return {
  -- Colors / theme
  { "catppuccin/nvim", name = "catppuccin" },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    dependencies = { "catppuccin" },
    config = function()
      local cs = require("plugins.colorscheme")
      cs.setup_catppuccin()
      cs.setup_gruvbox()
    end,
  },
  { "uZer/pywal16.nvim", name = "pywal16" },

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
  { "echasnovski/mini.icons" },
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
    cmd = { "SessionLoad", "SessionLoadLast", "SessionSelect", "SessionStop", "PersistenceLoad", "PersistenceSelect", "PersistenceStop" },
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

  -- Navigation / files / terminal
  { "MunifTanjim/nui.nvim" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    config = function()
      require("plugins.neo-tree")
    end,
  },
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    config = function()
      require("plugins.fzf-lua")
    end,
  },
  {
    "numToStr/FTerm.nvim",
    config = function()
      require("plugins.fterm")
    end,
  },
  { "famiu/bufdelete.nvim" },
  { "emmanueltouzery/decisive.nvim" },

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
    config = function()
      require("plugins.comment")
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
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    config = function()
      require("plugins.neogit")
    end,
  },

  -- LSP / tooling
  {
    "williamboman/mason.nvim",
    lazy = false,
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
  { "onsails/lspkind.nvim" },

  -- DAP / notebooks / AI helper
  {
    "mfussenegger/nvim-dap",
    ft = { "python" },
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
    lazy = false,
    config = function()
      require("plugins.molten")
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      require("plugins.ipynb")
    end,
  },
  {
    "NickvanDyke/opencode.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.opencode")
    end,
  },

  -- Shared deps / language extras
  { "nvim-lua/plenary.nvim" },
  { "mrcjkb/rustaceanvim", ft = { "rust" } },
  { "kaarmu/typst.vim", ft = { "typst" } },
  { "cdelledonne/vim-cmake", ft = { "c", "cpp", "cmake" } },
  { "antoinemadec/FixCursorHold.nvim" },
  { "alepez/vim-gtest", ft = { "c", "cpp" } },
}
