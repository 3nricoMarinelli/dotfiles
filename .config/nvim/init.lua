-- Disable swap files globally for .ipynb files (must be before lazy.nvim)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre", "BufRead" }, {
  pattern = "*.ipynb",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
  end,
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
