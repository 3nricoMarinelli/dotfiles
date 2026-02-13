require('git-conflict').setup {
  default_mappings = false, -- disable default keymaps, we'll set custom ones
  default_commands = true, -- enable commands
  disable_diagnostics = false, -- keep diagnostics enabled
  list_opener = 'copen', -- open conflicts in quickfix
  highlights = {
    incoming = 'DiffAdd',
    current = 'DiffText',
    ancestor = 'DiffChange',
  }
}
