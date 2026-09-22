-- Comment.nvim and documentation keybindings
-- Single source of truth for commenting and doc generation

local km = require("config.keymap-helper")
local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

-- Normal mode: toggle current line
km.register("n", "<leader>/", function()
  require("Comment.api").toggle.linewise.current()
end, "comment line")

-- Normal mode: toggle current block
km.register("n", "<leader>?", function()
  require("Comment.api").toggle.blockwise.current()
end, "comment block")

-- Visual mode: toggle linewise comment on selection
km.register("x", "<leader>/", function()
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, "comment selection")

-- Visual mode: toggle blockwise comment on selection
km.register("x", "<leader>?", function()
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.blockwise(vim.fn.visualmode())
end, "comment block selection")

-- License header generator
km.register("n", "<leader>cl", function()
  require("tools.license").insert_header()
end, "insert license header")

-- vim-doge documentation generator (Doxygen / JSDoc / Docstrings)
km.register("n", "<leader>d", function()
  vim.fn["doge#generate"]()
end, "generate doc comment")

return {}
