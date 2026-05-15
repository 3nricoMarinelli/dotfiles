local wk = require("which-key")
wk.add({
  -- ============================================================================
  -- TELESCOPE (FILE FINDING)
  -- ============================================================================
  { "<leader>f", group = "telescope" },

  -- ============================================================================
  -- DOCUMENTATION & COMMENTS
  -- ============================================================================
  { "<leader>d", group = "docs" },

  -- ============================================================================
  -- GIT / VERSION CONTROL
  -- ============================================================================
  { "<leader>g", group = "git" },

  -- ============================================================================
  -- LANGUAGE-SPECIFIC GROUPS (conditionally registered per file type)
  -- LSP    - <leader>l* (visible when LSP is active)
  -- DAP    - <leader>D* (visible when DAP is available)
  -- BUILD  - <leader>c* (visible for C/C++ files)
  -- PYTHON - <leader>p* (visible for Python/Quarto files)
  -- Registered in: lsp/keymaps.lua, dap/keymaps.lua, build/keymaps.lua, plugins/python.lua
  -- ============================================================================

  -- ============================================================================
  -- NORMAL MODE KEYBINDINGS (non-<leader> prefix, universal)
  -- ============================================================================
  { "[d", desc = "prev diagnostic" },
  { "]d", desc = "next diagnostic" },
  { "K", desc = "hover docs" },
})
