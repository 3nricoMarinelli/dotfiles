local km = require("config.keymap-helper")
local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

km.register("n", "<leader>/", function()
  local ok, api = pcall(require, "Comment.api")
  if ok then
    api.toggle.linewise.current()
  else
    vim.cmd("normal gcc")
  end
end, "comment line")

km.register("n", "<leader>?", function()
  local ok, api = pcall(require, "Comment.api")
  if ok then
    api.toggle.blockwise.current()
  else
    vim.cmd("normal gbc")
  end
end, "comment block")

km.register("x", "<leader>/", function()
  local ok, api = pcall(require, "Comment.api")
  if ok then
    vim.api.nvim_feedkeys(esc, "nx", false)
    api.toggle.linewise(vim.fn.visualmode())
  else
    vim.api.nvim_feedkeys("gc", "m", false)
  end
end, "comment selection")

km.register("x", "<leader>?", function()
  local ok, api = pcall(require, "Comment.api")
  if ok then
    vim.api.nvim_feedkeys(esc, "nx", false)
    api.toggle.blockwise(vim.fn.visualmode())
  else
    vim.api.nvim_feedkeys("gb", "m", false)
  end
end, "comment block selection")

km.register("n", "<leader>cl", function()
  require("tools.license").insert_header()
end, "insert file header")

km.register("n", "<leader>d", function()
  vim.fn["doge#generate"]()
end, "generate doc comment")

return {}
