require('diffview').setup {
  diff_binaries = false,
  enhanced_diff_hl = true, -- better syntax highlighting in diffs
  use_icons = true,
  show_help_hints = true,
  view = {
    default = {
      layout = "diff2_horizontal",
      winbar_info = true,
    },
    merge_tool = {
      layout = "diff3_mixed", -- 3-way merge: OURS | BASE | THEIRS
      disable_diagnostics = true,
      winbar_info = true,
    },
    file_history = {
      layout = "diff2_horizontal",
      winbar_info = true,
    },
  },
  file_panel = {
    listing_style = "tree",
    tree_options = {
      flatten_dirs = true,
      folder_statuses = "only_folded",
    },
    win_config = {
      position = "left",
      width = 35,
      win_opts = {}
    },
  },
  key_bindings = {
    disable_defaults = false,
    view = {
      { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      { "n", "<leader>dc", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
    },
    file_panel = {
      { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      { "n", "<leader>dc", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
    },
  },
  hooks = {
    diff_buf_read = function()
      vim.opt_local.wrap = false
      vim.opt_local.list = false
      vim.opt_local.colorcolumn = ""
    end,
  },
}
