local options = {
	encoding = "utf-8",
	fileencoding = "utf-8",
	laststatus = 3,
	ruler = false, --disable extra numbering
	showmode = false, --not needed due to lualine
	showcmd = false,
	wrap = true, --toggle bound to leader W
	mouse = "a", --enable mouse
	clipboard = "unnamedplus", --system clipboard integration
	history = 100, --command line history
	swapfile = false, --swap just gets in the way, usually
	backup = false,
	undofile = true, --undos are saved to file
	cursorline = true, --highlight line
	ttyfast = true, --faster scrolling
	smoothscroll = true,
	title = true, --automatic window titlebar

	number = true, --numbering lines
	relativenumber = true, --toggle bound to leader nn
	numberwidth = 4,

	smarttab = true, --indentation stuff
	cindent = true,
	autoindent = false,
	expandtab = true, --convert tabs to spaces
	tabstop = 4, --visual width of tab (4 spaces)
	shiftwidth = 4, --indent width for autoindent (4 spaces)
	softtabstop = 4, --number of spaces for <Tab> in insert mode

	foldmethod = "expr",
	foldlevel = 99, --disable folding, lower #s enable
	foldexpr = "nvim_treesitter#foldexpr()",

	termguicolors = true,

	ignorecase = true, --ignore case while searching
	smartcase = true, --but do not ignore if caps are used

	conceallevel = 2, --markdown conceal
	concealcursor = "nc",

	splitkeep = 'screen', --stablizie window open/close
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- highlight trailing whitespace in dark pastel red (Catppuccin maroon)
vim.cmd([[highlight ExtraWhitespace ctermbg=darkred guibg=#eba0ac]])

vim.diagnostic.config({
	signs = false,
})

-- Disable unused providers to reduce startup warnings
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Suppress vim.validate deprecation warnings from cmp-buffer
-- (plugin maintainer reverted the fix, will be resolved eventually)
local notify = vim.notify
vim.notify = function(msg, level, opts)
    if msg:match("vim.validate is deprecated") then
        return
    end
    notify(msg, level, opts)
end
