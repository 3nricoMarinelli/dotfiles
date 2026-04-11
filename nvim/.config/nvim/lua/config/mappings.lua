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
km.register("n", "<leader>q", ":BufferClose<CR>", "close buffer")
km.register("n", "<leader>Q", ":qa!<CR>", "force quit nvim")
km.register("n", "<leader>U", ":bufdo bd<CR>", "close ALL buffers")
km.register("n", "<leader>v", ":vsplit<CR>:bnext<CR>", "vsplit next buf")

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
km.register("n", "<leader>nn", function()
	if vim.wo.relativenumber then
		vim.wo.relativenumber = false
		vim.wo.number = true
	else
		vim.wo.relativenumber = true
	end
end, "toggle relative nums")

-- Vanilla Neovim: Search & Replace
km.register("n", "<leader>R", ":%s//g<Left><Left>", "replace all")

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

-- Plugins: FZF-lua
km.register("n", "<leader>f", ":lua require('fzf-lua').files()<CR>", "fzf files cwd", { group = "fzf" })
km.register("n", "<leader>Fh", ":lua require('fzf-lua').files({ cwd = '~/' })<CR>", "fzf files home", { group = "fzf" })
km.register("n", "<leader>Fc", ":lua require('fzf-lua').files({ cwd = '~/.config' })<CR>", "fzf files .config", { group = "fzf" })
km.register("n", "<leader>Fl", ":lua require('fzf-lua').files({ cwd = '~/.local/src' })<CR>", "fzf files .local/src", { group = "fzf" })
km.register("n", "<leader>Ff", ":lua require('fzf-lua').files({ cwd = '..' })<CR>", "fzf files parent", { group = "fzf" })
km.register("n", "<leader>Fr", ":lua require('fzf-lua').resume()<CR>", "fzf resume", { group = "fzf" })
km.register("n", "<leader>gg", ":lua require('fzf-lua').grep()<CR>", "grep", { group = "grep" })
km.register("n", "<leader>gw", ":lua require('fzf-lua').grep_cword()<CR>", "grep word under cursor", { group = "grep" })

-- Plugins: Comment.nvim
km.register("n", "<leader>/", function() require('Comment.api').toggle.linewise.current() end, "comment line", { group = "comment" })
km.register("n", "<leader>?", function() require('Comment.api').toggle.blockwise.current() end, "comment block", { group = "comment" })
km.register("v", "<leader>/", "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", "comment selection")
km.register("v", "<leader>?", "<ESC><CMD>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>", "comment block selection")

-- Plugins: Neogit (git interface)
km.register("n", "<leader>gs", function() require("neogit").open({ kind = "tab" }) end, "git status", { group = "git" })
km.register("n", "<leader>gc", function() require("neogit").action("Commit", "commit", {})() end, "git commit", { group = "git" })
km.register("n", "<leader>gu", function() require("neogit").action("Pull", "pull", {})() end, "git pull", { group = "git" })
km.register("n", "<leader>gp", function() require("neogit").action("Push", "push", {})() end, "git push", { group = "git" })

-- Plugins: Diffview (git diff visualization)
km.register("n", "<leader>gd", ":DiffviewOpen<CR>", "diff open", { group = "git" })
km.register("n", "<leader>gD", ":DiffviewClose<CR>", "diff close", { group = "git" })
km.register("n", "<leader>gh", ":DiffviewFileHistory<CR>", "file history", { group = "git" })

-- Plugins: Gitsigns (git signs + hunks)
km.register("n", "<leader>ga", function() require("gitsigns").stage_hunk() end, "stage hunk", { group = "git" })
km.register("n", "<leader>gU", function() require("gitsigns").undo_stage_hunk() end, "undo stage hunk", { group = "git" })
km.register("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, "reset hunk", { group = "git" })
km.register("n", "<leader>gv", function() require("gitsigns").preview_hunk() end, "preview hunk", { group = "git" })
km.register("n", "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, "blame line", { group = "git" })
km.register("n", "<leader>gj", function() require("gitsigns").next_hunk() end, "next hunk", { group = "git" })
km.register("n", "<leader>gk", function() require("gitsigns").prev_hunk() end, "prev hunk", { group = "git" })

-- Plugins: Neo-tree (file explorer)
km.register("n", "<leader>t", ":Neotree filesystem reveal left<CR>", "reveal tree", { group = "tree" })
km.register("n", "T", ":Neotree filesystem toggle<CR>", "toggle tree")

-- Plugins: Comment & Miscellaneous UI
km.register("n", "<leader>p", switch_theme, "toggle theme")
km.register("n", "<leader>w", ":w<CR>", "write file")

-- Plugins: FTerm (floating terminal)
km.register("n", "<leader>z", ":lua require('FTerm').open()<CR>", "floating terminal")
km.register("t", "<Esc>", "<C-\\><C-n><CMD>lua require('FTerm').close()<CR>", "close terminal")

-- Plugins: File operations
km.register("n", "<leader>m", ":!mv % ", "move file")

-- Plugins: lazy.nvim
km.register("n", "<leader>P", ":Lazy sync<CR>", "plugins sync")

-- Plugins: CMake (C/C++)
km.register("n", "<leader>cg", ":CMakeGenerate<CR>", "cmake generate", { group = "cmake" })
km.register("n", "<leader>cb", ":CMakeBuild<CR>", "cmake build", { group = "cmake" })

-- Plugins: GoogleTest (C/C++)
km.register("n", "<leader>ct", ":GTestRunUnderCursor<CR>", "gtest run", { group = "cmake" })

-- Plugins: NvimDAP (debugging)
-- Mappings can be added here when DAP is configured for specific languages

-- Plugins: Molten (Jupyter)
-- Mappings can be added here when Molten is configured

-- Plugins: OpenCode (AI assistant)
-- Mappings can be added here when OpenCode is configured

-- Plugins: FZF-launcher (startup picker with Tab toggle)
-- Auto-launched on VimEnter, no manual mapping needed
-- Tab toggles between Files and Grep within picker
