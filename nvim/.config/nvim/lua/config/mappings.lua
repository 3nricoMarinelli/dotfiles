-- mappings, including plugins
--
-- C/C++/Python/Rust/Typst Development (inspired by cacharle/dotfiles):
--
-- LSP Keybindings:
--   gd - Go to definition
--   K - Hover documentation
--   gk - Signature help
--   <leader>rn - Rename symbol
--   <leader>ld - LSP diagnostics (Telescope or quickfix)
--   <leader>ls - LSP workspace symbols (C/C++ only)
--   <leader>lr - LSP references
--   [d / ]d - Previous/next diagnostic
--
-- C/C++ Utilities:
--   <leader>aw - ArgWrap: toggle single/multi-line function arguments
--   ga - EasyAlign: align on delimiter (visual or operator mode)
--
-- C/C++ CMake & Testing:
--   <leader>cg - CMake: generate build files
--   <leader>cb - CMake: build project
--   <leader>gt - GoogleTest: run test under cursor
--
-- Python Utilities:
--   <leader>ba - Add breakpoint() at current line
--   <leader>bd - Delete all breakpoint() lines
--
-- Typst Utilities:
--   <leader>tc - Compile current file (typst compile)
--   <leader>tw - Watch & auto-compile (typst watch)
--
-- Completion (nvim-cmp):
--   <Tab> - Confirm selection
--   <C-n> - Next item / trigger completion
--   <C-p> - Previous item
--   <C-b/f> - Scroll docs
--
-- Installation:
--   C/C++: brew install llvm (for clangd)
--   Python: pip install 'python-lsp-server[all]' pyls-flake8
--   Rust: rustup component add rust-analyzer
--   Typst: cargo install typst-lsp && brew install typst
--   Tools: brew install fswatch (for compile-on-save script)

local function map(m, k, v)
	vim.keymap.set(m, k, v, { noremap = true, silent = true })
end

-- set leader
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- buffers
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")
map("n", "<leader>q", ":BufferClose<CR>")
map("n", "<leader>Q", ":BufferClose!<CR>")
map("n", "<leader>U", "::bufdo bd<CR>") --close all
map('n', '<leader>vs', ':vsplit<CR>:bnext<CR>') --ver split + open next buffer

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
map("n", "<leader>Fr", ":lua require('fzf-lua').resume()<CR>") --last search
map("n", "<leader>g", ":lua require('fzf-lua').grep()<CR>") --grep
map("n", "<leader>G", ":lua require('fzf-lua').grep_cword()<CR>") --grep word under cursor

-- misc
map("n", "<leader>s", ":%s//g<Left><Left>") --replace all
map("n", "<leader>t", ":NvimTreeToggle<CR>") --open file explorer
map("n", "<leader>p", switch_theme) --cycle themes
map("n", "<leader>P", ":PlugInstall<CR>") --vim-plug
map('n', '<leader>z', ":lua require('FTerm').open()<CR>") --open term
map('t', '<Esc>', '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>') --preserves session
map("n", "<leader>w", ":w<CR>") --write but one less key
map("n", "<leader>dd", ":w ") --duplicate to new name
map("n", "<leader>x", "<cmd>!chmod +x %<CR>") --make a file executable
map("n", "<leader>mv", ":!mv % ") --move a file to a new dir
map("n", "<leader>R", ":so %<CR>") --reload neovim config
map("n", "<leader>u", ':silent !xdg-open "<cWORD>" &<CR>') --open a url under cursor
map("v", "<leader>i", "=gv") --auto indent
map("n", "<leader>W", ":set wrap!<CR>") --toggle wrap

-- decisive csv
map("n", "<leader>csa", ":lua require('decisive').align_csv({})<cr>")
map("n", "<leader>csA", ":lua require('decisive').align_csv_clear({})<cr>")
map("n", "[c", ":lua require('decisive').align_csv_prev_col()<cr>")
map("n", "]c", ":lua require('decisive').align_csv_next_col()<cr>")

-- Git Workflow (git-conflict.nvim + gitsigns.nvim)
--
-- Merge Conflict Resolution (git-conflict.nvim):
--   <leader>co - Choose ours (current branch)
--   <leader>ct - Choose theirs (incoming branch)
--   <leader>cb - Choose both changes
--   <leader>c0 - Choose none (delete conflict)
--   <leader>cn - Next conflict
--   <leader>cp - Previous conflict
--   <leader>cl - List all conflicts (quickfix)
--
-- Hunk Operations (gitsigns.nvim):
--   <leader>hs - Stage hunk
--   <leader>hu - Undo/reset hunk
--   <leader>hp - Preview hunk
--   <leader>hb - Blame line
--   <leader>hd - Diff this file
--   ]h / [h - Next/previous hunk

-- git-conflict.nvim keybindings
map('n', '<leader>co', '<cmd>GitConflictChooseOurs<cr>', { desc = 'Choose ours (current)' })
map('n', '<leader>ct', '<cmd>GitConflictChooseTheirs<cr>', { desc = 'Choose theirs (incoming)' })
map('n', '<leader>cb', '<cmd>GitConflictChooseBoth<cr>', { desc = 'Choose both' })
map('n', '<leader>c0', '<cmd>GitConflictChooseNone<cr>', { desc = 'Choose none' })
map('n', '<leader>cn', '<cmd>GitConflictNextConflict<cr>', { desc = 'Next conflict' })
map('n', '<leader>cp', '<cmd>GitConflictPrevConflict<cr>', { desc = 'Previous conflict' })
map('n', '<leader>cl', '<cmd>GitConflictListQf<cr>', { desc = 'List conflicts' })

-- gitsigns.nvim keybindings (hunk operations)
map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
map('n', '<leader>hu', ':Gitsigns undo_stage_hunk<CR>', { desc = 'Undo stage hunk' })
map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
map('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', { desc = 'Preview hunk' })
map('n', '<leader>hb', ':Gitsigns blame_line<CR>', { desc = 'Blame line' })
map('n', '<leader>hd', ':Gitsigns diffthis<CR>', { desc = 'Diff this' })
map('n', ']h', ':Gitsigns next_hunk<CR>', { desc = 'Next hunk' })
map('n', '[h', ':Gitsigns prev_hunk<CR>', { desc = 'Previous hunk' })



map("n", "<leader>H", function() --toggle htop in term
    _G.htop:toggle()
end)


map("n", "<leader>ma", function() --quick make in dir of buffer
	local bufdir = vim.fn.expand("%:p:h")
	vim.cmd("lcd " .. bufdir)
	vim.cmd("!sudo make uninstall && sudo make clean install %")
end)

-- C/C++/Rust utilities from cacharle's config
map("x", "ga", "<cmd>EasyAlign<cr>") --align selected text
map("n", "ga", "<cmd>EasyAlign<cr>") --align operator

-- CMake integration (lazy loaded for C/C++ files)
map("n", "<leader>cg", ":CMakeGenerate<CR>") --generate CMake build files
map("n", "<leader>cb", ":CMakeBuild<CR>") --build CMake project

-- GoogleTest integration (lazy loaded for C/C++ files)
map("n", "<leader>ct", ":GTestRunUnderCursor<CR>") --run test under cursor

-- ArgWrap: toggle function arguments between single/multi-line
-- Will be configured with C/C++ specific settings (no trailing comma)
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local argwrap_ok = pcall(vim.cmd, "ArgWrap")
		if argwrap_ok then
			vim.g.argwrap_tail_comma = 1
			map("n", "<leader>aw", "<cmd>ArgWrap<cr>")

			-- C/C++ specific: no trailing comma
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "c", "cpp" },
				callback = function()
					vim.g.argwrap_tail_comma = 0
					vim.g.argwrap_wrap_closing_brace = 0
				end,
			})
		end
	end,
})


map("n", "<leader>nn", function() --toggle relative vs absolute line numbers
	if vim.wo.relativenumber then
		vim.wo.relativenumber = false
		vim.wo.number = true
	else
		vim.wo.relativenumber = true
	end
end)
