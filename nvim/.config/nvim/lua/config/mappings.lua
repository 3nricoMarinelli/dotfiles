-- mappings, including plugins

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
-- last search
map("n", "<leader>Fr", ":lua require('fzf-lua').resume()<CR>")
map("n", "<leader>sg", ":lua require('fzf-lua').grep()<CR>") --grep
map("n", "<leader>sw", ":lua require('fzf-lua').grep_cword()<CR>") --grep word under cursor

-- misc
map("n", "<leader>R", ":%s//g<Left><Left>") --replace all
map("n", "<leader>t", ":NvimTreeToggle<CR>") --open file explorer
map("n", "<leader>p", switch_theme) --cycle themes
map("n", "<leader>P", ":PlugUpgrade | PlugInstall | PlugUpdate<CR>") --vim-plug
map('n', '<leader>z', ":lua require('FTerm').open()<CR>") --open term
map('t', '<Esc>', '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>') --preserves session
map("n", "<leader>w", ":w<CR>") --write but one less key
map("n", "<leader>dd", ":w ") --duplicate to new name
map("n", "<leader>x", "<cmd>!chmod +x %<CR>") --make a file executable
map("n", "<leader>mv", ":!mv % ") --move a file to a new dir
map("n", "<leader>rl", ":so %<CR>") --reload neovim config
map("v", "<leader>i", "=gv") --auto indent
map("n", "<leader>W", ":set wrap!<CR>") --toggle wrap

-- decisive csv
map("n", "<leader>csa", ":lua require('decisive').align_csv({})<cr>")
map("n", "<leader>csA", ":lua require('decisive').align_csv_clear({})<cr>")
map("n", "[c", ":lua require('decisive').align_csv_prev_col()<cr>")
map("n", "]c", ":lua require('decisive').align_csv_next_col()<cr>")

-- Git mappings (starting with g)
-- Disable Neovim 0.10+ and 0.11 default mappings to avoid overlaps with git
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Disable built-in comment and LSP mappings that start with g
        pcall(vim.keymap.del, "n", "gc")
        pcall(vim.keymap.del, "n", "gcc")
        pcall(vim.keymap.del, "n", "grn")
        pcall(vim.keymap.del, "n", "gra")
        pcall(vim.keymap.del, "n", "grr")
        pcall(vim.keymap.del, "n", "gri")
        pcall(vim.keymap.del, "n", "grt")
        pcall(vim.keymap.del, "x", "gra")
    end
})

-- Neogit
map('n', 'gs', '<cmd>Neogit<cr>', { desc = 'Git status (Neogit)' })
map('n', 'gc', '<cmd>Neogit commit<cr>', { desc = 'Git commit (Neogit)' })
map('n', 'gu', '<cmd>Neogit pull<cr>', { desc = 'Git pull (Neogit)' })
map('n', 'gp', '<cmd>Neogit push<cr>', { desc = 'Git push (Neogit)' })
-- Diffview
map('n', 'gd', '<cmd>DiffviewOpen<cr>', { desc = 'Open Diffview' })
map('n', 'gD', '<cmd>DiffviewClose<cr>', { desc = 'Close Diffview' })
map('n', 'gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history' })

-- Gitsigns (starting with g)
map('n', 'ga', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
map('v', 'ga', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
map('n', 'gU', ':Gitsigns undo_stage_hunk<CR>', { desc = 'Undo stage hunk' })
map('n', 'gr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
map('v', 'gr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
map('n', 'gv', ':Gitsigns preview_hunk<CR>', { desc = 'Preview hunk' })
map('n', 'gb', ':Gitsigns blame_line<CR>', { desc = 'Blame line' })
map('n', 'gj', ':Gitsigns next_hunk<CR>', { desc = 'Next hunk' })
map('n', 'gk', ':Gitsigns prev_hunk<CR>', { desc = 'Previous hunk' })

map("n", "<leader>H", function() --toggle htop in term
    _G.htop:toggle()
end)


map("n", "<leader>ma", function() --quick make in dir of buffer
	local bufdir = vim.fn.expand("%:p:h")
	vim.cmd("lcd " .. bufdir)
	vim.cmd("!sudo make uninstall && sudo make clean install %")
end)

-- C/C++/Rust utilities from cacharle's config
map("x", "<leader>al", "<cmd>EasyAlign<cr>") --align selected text
map("n", "<leader>al", "<cmd>EasyAlign<cr>") --align operator



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
		if vim.fn.exists(":ArgWrap") > 0 then
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
