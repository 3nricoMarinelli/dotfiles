local wk = require("which-key")

wk.setup()

wk.add({
  -- Prefix groups
  { "<leader>g", group = "git" },
  { "<leader>c", group = "C++ / Build" },
  { "<leader>l", group = "LSP" },
  { "<leader>D", group = "debugger" },
  { "<leader>p", group = "python / jupyter" },

  -- Universal motions
  { "[d", desc = "prev diagnostic" },
  { "]d", desc = "next diagnostic" },
  { "K", desc = "hover docs" },
})

