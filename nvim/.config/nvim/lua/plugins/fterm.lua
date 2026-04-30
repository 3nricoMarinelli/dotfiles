local fterm = require("FTerm")

-- Configure FTerm to use the system's $TERM value
fterm.setup({
  env = {
    TERM = vim.env.TERM or "xterm-256color",
    FLOATING_TERM = 1,
  },
})

_G.htop = fterm:new({
  ft = "fterm_htop",
  cmd = "htop",
})
