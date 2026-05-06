local wk = require("which-key")
wk.add({
  -- ============================================================================
  -- MISC / GENERAL
  -- ============================================================================
  { "<leader>u", desc = "open url" },
  { "<leader>z", desc = "floating terminal" },
  { "<leader>W", desc = "toggle wrap" },
  { "<leader>R", desc = "replace all" },
  { "<leader>nn", desc = "toggle relative nums" },
  { "<leader>P", desc = "plugins sync" },
  { "<leader>i", desc = "auto indent" },

  -- ============================================================================
  -- BUFFERS (remapped for LSP compatibility)
  -- ============================================================================
  -- NOTE: <leader>q is now buffer close (see BUFFERS section)
  --       <leader>p is now workspace symbols (see LSP section)
  { "<leader>q", desc = "close buffer" },
  { "<leader>Q", desc = "force quit" },
  { "<leader>U", desc = "close all buffers" },
  { "<leader>v", desc = "vsplit buffer" },

  -- ============================================================================
  -- FILE TREE / EXPLORER
  -- ============================================================================
  { "<leader>t", desc = "reveal tree", nowait = true }, -- nowait to allow <leader>tc etc.
  { "<leader>tl", desc = "toggle linting" },
  { "T", desc = "toggle tree" },

  -- ============================================================================
  -- TELESCOPE (FILE FINDING)
  -- ============================================================================
  { "<leader>f", group = "telescope" },
  { "<leader>Fh", desc = "find home" },
  { "<leader>Fc", desc = "find config" },
  { "<leader>Fl", desc = "find .local" },
  { "<leader>Ff", desc = "find parent" },
  { "<leader>Fr", desc = "resume" },

  -- ============================================================================
  -- SEARCH / REPLACE
  -- ============================================================================
  { "<leader>s", desc = "live grep" },
  { "<leader>Sr", desc = "search/replace all" },

  -- ============================================================================
  -- COMMENTS
  -- ============================================================================
  { "<leader>/", desc = "comment line" },
  { "<leader>?", desc = "comment block" },

  -- ============================================================================
  -- GIT / VERSION CONTROL
  -- ============================================================================
  { "<leader>g", group = "git" },
  { "<leader>gs", desc = "status" },
  { "<leader>gc", desc = "commit" },
  { "<leader>gu", desc = "pull" },
  { "<leader>gp", desc = "push" },
  { "<leader>gd", desc = "diff open" },
  { "<leader>gD", desc = "diff close" },
  { "<leader>gh", desc = "history" },
  { "<leader>ga", desc = "stage" },
  { "<leader>gU", desc = "unstage" },
  { "<leader>gr", desc = "reset" },
  { "<leader>gv", desc = "preview" },
  { "<leader>gb", desc = "blame" },
  { "<leader>gj", desc = "next" },
  { "<leader>gk", desc = "prev" },

  -- ============================================================================
  -- LSP (UNIFIED ACROSS ALL LANGUAGES)
  -- ============================================================================
  -- Navigation
  { "<leader>l", group = "LSP" },
  { "<leader>ld", desc = "go definition" },
  { "<leader>]", desc = "go definition" },
  { "<leader>lD", desc = "go declaration" },
  { "<leader>[", desc = "go declaration" },

  -- Refactoring
  { "<leader>r", desc = "rename symbol" },
  { "<leader>rn", desc = "rename symbol" },
  { "<leader>la", desc = "code action" },

  -- Discovery
  { "<leader>li", desc = "implementations" },
  { "<leader>lt", desc = "type definition" },
  { "<leader>lr", desc = "show references" },
  { "<leader>p", desc = "workspace symbols" },

  -- Diagnostics
  { "<leader>lx", desc = "list diagnostics" },
  { "<leader>x", desc = "list diagnostics" },

  -- ============================================================================
  -- C/C++ TOOLS
  -- ============================================================================
  { "<leader>c", group = "C/C++" },
  { "<leader>cg", desc = "cmake generate" },
  { "<leader>cb", desc = "cmake build" },
  { "<leader>ct", desc = "gtest run" },

  -- ============================================================================
  -- TYPST (COMPILATION)
  -- ============================================================================
  -- Note: <leader>t is tree (with nowait), <leader>tc/tw are typst
  -- This works because typst bindings are only active in .typ files
  { "<leader>tc", desc = "typst compile" },
  { "<leader>tw", desc = "typst watch" },

  -- ============================================================================
  -- PYTHON (DEBUGGING / BREAKPOINTS)
  -- ============================================================================
  -- Note: <leader>p is workspace symbols (LSP), so breakpoints use <leader>pb/pB
  { "<leader>pb", desc = "add breakpoint" },
  { "<leader>pB", desc = "delete breakpoints" },

  -- ============================================================================
  -- DAP DEBUGGER (C/C++, Python, etc.)
  -- ============================================================================
  { "<leader>d", group = "debugger" },
  { "<leader>db", desc = "toggle breakpoint" },
  { "<leader>dc", desc = "continue" },
  { "<leader>do", desc = "step over" },
  { "<leader>di", desc = "step into" },
  { "<leader>dO", desc = "step out" },
  { "<leader>dq", desc = "terminate" },
  { "<leader>du", desc = "toggle UI" },

  -- ============================================================================
  -- MOLTEN (JUPYTER NOTEBOOKS)
  -- ============================================================================
  { "<leader>m", group = "molten" },
  { "<leader>mi", desc = "init kernel" },
  { "<leader>mc", desc = "run cell" },
  { "<leader>me", desc = "evaluate" },
  { "<leader>ml", desc = "eval line" },
  { "<leader>mr", desc = "re-evaluate" },
  { "<leader>mo", desc = "output window" },
  { "<leader>mx", desc = "interrupt kernel" },
  { "<leader>mq", desc = "deinit kernel" },
  { "<leader>md", desc = "delete output" },

  -- ============================================================================
  -- OPENCODE (AI ASSISTANT)
  -- ============================================================================
  { "<leader>o", group = "opencode" },
  { "<leader>ot", desc = "toggle embedded" },
  { "<leader>oa", desc = "ask about" },
  { "<leader>o+", desc = "add prompt" },
  { "<leader>oe", desc = "explain code" },
  { "<leader>on", desc = "new session" },
  { "<leader>os", desc = "select prompt" },

  -- ============================================================================
  -- NORMAL MODE KEYBINDINGS (non-<leader> prefix)
  -- ============================================================================
  { "[d", desc = "prev diagnostic" },
  { "]d", desc = "next diagnostic" },
  { "K", desc = "hover docs" },
  { "gk", desc = "signature help" },
})
