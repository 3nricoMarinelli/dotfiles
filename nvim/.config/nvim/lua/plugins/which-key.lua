-- which-key configuration synchronized with global and buffer keymaps
local wk = require("which-key")

wk.setup()

wk.add({
  -- Prefix groups
  { "<leader>c", group = "code / tools" },
  { "<leader>g", group = "git" },
  { "<leader>l", group = "lsp" },
  { "<leader>t", group = "theme" },
  { "<leader>p", group = "python / jupyter" },
  { "<leader>D", group = "debugger" },

  -- Top-level leader keymaps
  { "<leader>f", desc = "files (git root)" },
  { "<leader>F", desc = "grep (git root)" },
  { "<leader>e", desc = "toggle tree" },
  { "<leader>x", desc = "close buffer" },
  { "<leader>z", desc = "floating terminal" },
  { "<leader>n", desc = "toggle relative nums" },
  { "<leader>R", desc = "search & replace word" },
  { "<leader>r", desc = "replace selection" },
  { "<leader>W", desc = "toggle wrap" },
  { "<leader>P", desc = "plugins sync" },
  { "<leader>/", desc = "comment line" },
  { "<leader>?", desc = "comment block" },
  { "<leader>d", desc = "generate doc comment" },

  -- Code / tools
  { "<leader>cf", desc = "create file in dir" },
  { "<leader>cl", desc = "insert file header" },

  -- Theme
  { "<leader>ts", desc = "select theme" },
  { "<leader>tn", desc = "next theme" },
  { "<leader>tp", desc = "prev theme" },

  -- Git
  { "<leader>gs", desc = "git status" },
  { "<leader>ga", desc = "stage hunk" },
  { "<leader>gu", desc = "unstage hunk" },
  { "<leader>gv", desc = "preview hunk" },
  { "<leader>gb", desc = "blame line" },
  { "<leader>gj", desc = "next hunk" },
  { "<leader>gk", desc = "prev hunk" },
  { "<leader>gr", desc = "reset hunk" },

  -- Universal motions & buffers
  { "[d", desc = "prev diagnostic" },
  { "]d", desc = "next diagnostic" },
  { "K", desc = "hover docs" },
  { "<C-Tab>", desc = "next buffer (screen order)" },
  { "<C-S-Tab>", desc = "prev buffer (screen order)" },
})

-- Flush any queued keymap-helper specs
local km_ok, km = pcall(require, "config.keymap-helper")
if km_ok and km.flush_which_key_specs then
  km.flush_which_key_specs()
end
