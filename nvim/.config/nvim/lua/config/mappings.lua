-- neovim keybindings
-- organized by: vanilla neovim → plugins
-- all mappings auto-register with which-key via keymap-helper

local km = require("config.keymap-helper")

vim.o.timeoutlen = 300 -- wait 300ms for next key in sequence
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Vanilla Neovim: Remove built-in keybindings
-- unmap 0.10+ commenting (we use <leader>/ and <leader>?)
vim.keymap.del("n", "gc")
vim.keymap.del("n", "gcc")
vim.keymap.del("x", "gc")

-- Vanilla Neovim: Buffers
km.register("n", "<S-l>", ":bnext<CR>", "next buffer")
km.register("n", "<S-h>", ":bprevious<CR>", "prev buffer")
km.register("n", "<C-S-Right>", ":bnext<CR>", "next buffer (alt)")
km.register("n", "<C-S-Left>", ":bprevious<CR>", "prev buffer (alt)")
km.register("n", "<leader>q", ":qa!<CR>", "force quit nvim")
km.register("n", "<leader>x", ":bd<CR>", "quit buffer")
km.register("n", "<leader>u", ":bufdo bd<CR>", "close ALL buffers")
km.register("n", "<leader>v", ":vsplit<CR>:bp<CR>", "vsplit next buf")

-- Vanilla Neovim: Windows
km.register("n", "<C-h>", "<C-w>h", "window left")
km.register("n", "<C-j>", "<C-w>j", "window down")
km.register("n", "<C-k>", "<C-w>k", "window up")
km.register("n", "<C-l>", "<C-w>l", "window right")
km.register("n", "<C-Left>", "<C-w>h", "window left (alt)")
km.register("n", "<C-Down>", "<C-w>j", "window down (alt)")
km.register("n", "<C-Up>", "<C-w>k", "window up (alt)")
km.register("n", "<C-Right>", "<C-w>l", "window right (alt)")
km.register("n", "<F5>", ":resize +2<CR>", "increase height")
km.register("n", "<F6>", ":resize -2<CR>", "decrease height")
km.register("n", "<F7>", ":vertical resize +2<CR>", "increase width")
km.register("n", "<F8>", ":vertical resize -2<CR>", "decrease width")

-- Vanilla Neovim: Line Numbers
km.register("n", "<leader>n", function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end, "toggle relative nums")

-- Vanilla Neovim: Search & Replace Everywhere Word under cursor
km.register("n", "<leader>R", ":%s/<C-r><C-w>//g<Left><Left>", "search and replace")

-- Vanilla Neovim: Replace Word
km.register("n", "<leader>r", "ve\"_dP", "replace")

-- Vanilla Neovim: Text Formatting
km.register("v", "<leader>i", "=gv", "auto indent selection")
km.register("n", "<leader>W", ":set wrap!<CR>", "toggle wrap")

-- Plugins: Barbar (buffer navigation)
km.register("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", "goto buffer 1")
km.register("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", "goto buffer 2")
km.register("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", "goto buffer 3")
km.register("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", "goto buffer 4")
km.register("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", "goto buffer 5")
km.register("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", "goto buffer 6")
km.register("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", "goto buffer 7")
km.register("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", "goto buffer 8")
km.register("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", "goto buffer 9")
km.register("n", "<A-0>", "<Cmd>BufferLast<CR>", "goto last buffer")
km.register("n", "<A-p>", "<Cmd>BufferPin<CR>", "pin/unpin buffer")
km.register("n", "<AS-h>", "<Cmd>BufferMovePrevious<CR>", "move buffer left")
km.register("n", "<AS-l>", "<Cmd>BufferMoveNext<CR>", "move buffer right")

-- Plugins: Telescope (git-root aware with Tab toggle)
-- <leader>f - Files in git root (or cwd), Tab toggles to grep
-- <leader>s - Grep in git root (or cwd), Tab toggles to files
-- Git root detection: finds first .git in parent dirs, falls back to cwd
km.register(
  "n",
  "<leader>f",
  ":lua require('utils.git-root-search').open_files()<CR>",
  "files (git root)",
  { group = "telescope" }
)
km.register(
  "n",
  "<leader>F",
  ":lua require('utils.git-root-search').open_grep()<CR>",
  "grep (git root)",
  { group = "search" }
)

-- Plugins: Comment.nvim
km.register("n", "<leader>/", function()
  require("Comment.api").toggle.linewise.current()
end, "comment line", { group = "docs" })
km.register("n", "<leader>?", function()
  require("Comment.api").toggle.blockwise.current()
end, "comment block", { group = "docs" })
km.register(
  "v",
  "<leader>/",
  "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  "comment selection",
  { group = "docs" }
)
km.register(
  "v",
  "<leader>?",
  "<ESC><CMD>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>",
  "comment block selection",
  { group = "docs" }
)

-- Plugins: Neogit (git interface)
km.register("n", "<leader>gs", function()
  require("neogit").open({ kind = "tab" })
end, "status")

-- Plugins: Gitsigns (git signs + hunks)
km.register("n", "<leader>ga", function()
  require("gitsigns").stage_hunk()
end, "stage")
km.register("n", "<leader>gu", function()
  require("gitsigns").undo_stage_hunk()
end, "unstage")
km.register("n", "<leader>gv", function()
  require("gitsigns").preview_hunk()
end, "preview")
km.register("n", "<leader>gb", function()
  require("gitsigns").blame_line({ full = true })
end, "blame")
km.register("n", "<leader>gj", function()
  require("gitsigns").next_hunk()
end, "next")
km.register("n", "<leader>gk", function()
  require("gitsigns").prev_hunk()
end, "prev")
km.register("n", "<leader>gr", function()
  require("gitsigns").reset_hunk()
end, "reset")

-- Plugins: Neo-tree (file explorer)
km.register(
  "n",
  "<leader>t",
  ":Neotree filesystem reveal left<CR>",
  "reveal tree",
  { group = "tree" }
)
km.register("n", "T", ":Neotree filesystem toggle<CR>", "toggle tree")

-- Plugins: FTerm (floating terminal)
km.register("n", "<leader>z", ":lua require('FTerm').open()<CR>", "floating terminal")
km.register("t", "<Esc>", "<C-\\><C-n><CMD>lua require('FTerm').close()<CR>", "close terminal")

-- Plugins: lazy.nvim
km.register("n", "<leader>P", ":Lazy sync<CR>", "plugins sync")

-- Plugins: vim-doge (documentation generation)
km.register("n", "<leader>d", function()
  vim.fn["doge#generate"]()
end, "generate doc comment", { group = "docs" })

-- Plugins: Python (breakpoint management, namespaced to <leader>p*)
-- <leader>pb and <leader>pB are set dynamically in python-lsp.lua on attach

-- Plugins: Typst (compilation, namespaced to <leader>t*)
-- <leader>tc and <leader>tw are set dynamically in typst-lsp.lua on attach

-- Plugins: NvimDAP (debugging)
-- Mappings can be added here when DAP is configured for specific languages

-- Plugins: Molten (Jupyter)
-- Mappings can be added here when Molten is configured

-- Plugins: OpenCode (AI assistant)
-- Mappings can be added here when OpenCode is configured

-- Plugins: Telescope (startup picker with Tab toggle)
-- Auto-launched on VimEnter, no manual mapping needed
-- Tab toggles between Files and Grep within picker
