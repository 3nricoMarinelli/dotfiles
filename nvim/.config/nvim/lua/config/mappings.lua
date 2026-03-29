-- mappings, including plugins

vim.o.timeoutlen = 300 --wait 300ms for next key in a sequence

local function map(m, k, v)
	vim.keymap.set(m, k, v, { noremap = true, silent = true })
end

-- set leader (do NOT map <Space> to <Nop> -- which-key v3 manages it natively)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Unmap built-in 0.10+ commenting to remove checkhealth warnings
-- since we use <leader>/ and <leader>?
vim.keymap.del("n", "gc")
vim.keymap.del("n", "gcc")
vim.keymap.del("x", "gc")

-- buffers
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")
map("n", "<leader>q", ":BufferClose<CR>")
map("n", "<leader>Q", "::qa!<CR>")
map("n", "<leader>U", ":bufdo bd<CR>") --close all
map('n', '<leader>v', ':vsplit<CR>:bnext<CR>') --ver split + open next buffer

-- buffer position nav + reorder
map('n', '<AS-h>', '<Cmd>BufferMovePrevious<CR>')
map('n', '<AS-l>', '<Cmd>BufferMoveNext<CR>')
map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>')
map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>')
map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>')
map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>')
map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>')
map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>')
map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>')
map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>')
map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>')
map('n', '<A-0>', '<Cmd>BufferLast<CR>')
map('n', '<A-p>', '<Cmd>BufferPin<CR>')

-- windows - ctrl nav, fn resize
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<F5>", ":resize +2<CR>")
map("n", "<F6>", ":resize -2<CR>")
map("n", "<F7>", ":vertical resize +2<CR>")
map("n", "<F8>", ":vertical resize -2<CR>")

-- fzf and grep
map("n", "<leader>f", ":lua require('fzf-lua').files()<CR>") --search cwd
map("n", "<leader>Fh", ":lua require('fzf-lua').files({ cwd = '~/' })<CR>") --search home
map("n", "<leader>Fc", ":lua require('fzf-lua').files({ cwd = '~/.config' })<CR>") --search .config
map("n", "<leader>Fl", ":lua require('fzf-lua').files({ cwd = '~/.local/src' })<CR>") --search .local/src
map("n", "<leader>Ff", ":lua require('fzf-lua').files({ cwd = '..' })<CR>") --search above
-- last search
map("n", "<leader>Fr", ":lua require('fzf-lua').resume()<CR>")
map("n", "<leader>gg", ":lua require('fzf-lua').grep()<CR>") --grep
map("n", "<leader>gw", ":lua require('fzf-lua').grep_cword()<CR>") --grep word under cursor

-- git (neogit + gitsigns + diffview)
map("n", "<leader>gs", function() require("neogit").open({ kind = "tab" }) end) --git status
map("n", "<leader>gc", function() require("neogit").action("Commit", "commit", {})() end) --git commit
map("n", "<leader>gu", function() require("neogit").action("Pull", "pull", {})() end) --git pull
map("n", "<leader>gp", function() require("neogit").action("Push", "push", {})() end) --git push
map("n", "<leader>gd", ":DiffviewOpen<CR>") --diff open
map("n", "<leader>gD", ":DiffviewClose<CR>") --diff close
map("n", "<leader>gh", ":DiffviewFileHistory<CR>") --file history
map("n", "<leader>ga", function() require("gitsigns").stage_hunk() end) --stage hunk
map("n", "<leader>gU", function() require("gitsigns").undo_stage_hunk() end) --undo stage hunk
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end) --reset hunk
map("n", "<leader>gv", function() require("gitsigns").preview_hunk() end) --preview hunk
map("n", "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end) --blame line
map("n", "<leader>gj", function() require("gitsigns").next_hunk() end) --next hunk
map("n", "<leader>gk", function() require("gitsigns").prev_hunk() end) --prev hunk

-- misc
map("n", "<leader>R", ":%s//g<Left><Left>") --replace all
map("n", "<leader>t", ":NvimTreeToggle<CR>") --open file explorer
map("n", "T", ":NvimTreeToggle<CR>") --single key open file explorer
map("n", "<leader>p", switch_theme) --cycle themes
map("n", "<leader>P", ":PlugUpgrade | PlugInstall | PlugUpdate<CR>") --vim-plug
map('n', '<leader>z', ":lua require('FTerm').open()<CR>") --open term
map('t', '<Esc>', '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>') --preserves session
map("n", "<leader>w", ":w<CR>") --write but one less key
map("n", "<leader>m", ":!mv % ") --move a file to a new dir
map("v", "<leader>i", "=gv") --auto indent
map("n", "<leader>W", ":set wrap!<CR>") --toggle wrap
map("n", "<leader>/", function() require('Comment.api').toggle.linewise.current() end) --toggle comment line
map("n", "<leader>?", function() require('Comment.api').toggle.blockwise.current() end) --toggle block comment
map("v", "<leader>/", "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>") --toggle comment visual
map("v", "<leader>?", "<ESC><CMD>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>") --toggle block visual

-- C/C++/Rust utilities from cacharle's config



-- CMake integration (lazy loaded for C/C++ files)
map("n", "<leader>cg", ":CMakeGenerate<CR>") --generate CMake build files
map("n", "<leader>cb", ":CMakeBuild<CR>") --build CMake project

-- GoogleTest integration (lazy loaded for C/C++ files)
map("n", "<leader>ct", ":GTestRunUnderCursor<CR>") --run test under cursor



map("n", "<leader>nn", function() --toggle relative vs absolute line numbers
	if vim.wo.relativenumber then
		vim.wo.relativenumber = false
		vim.wo.number = true
	else
		vim.wo.relativenumber = true
	end
end)
