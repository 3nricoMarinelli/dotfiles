-- which-key configuration with contextual groups and global keymaps
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

  -- Global leader keymaps
  { "<leader>f", desc = "files (git root)" },
  { "<leader>F", desc = "grep (git root)" },
  { "<leader>cf", desc = "create file in dir" },
  { "<leader>e", desc = "toggle tree" },
  { "<leader>gs", desc = "git status" },
  { "<leader>ts", desc = "select theme" },
  { "<leader>tn", desc = "next theme" },
  { "<leader>tp", desc = "prev theme" },
  { "<leader>z", desc = "floating terminal" },
  { "<leader>P", desc = "plugins sync" },

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
