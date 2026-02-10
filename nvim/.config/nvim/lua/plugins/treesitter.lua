require'nvim-treesitter'.setup {
	install_dir = vim.fn.stdpath('data') .. '/site'
}

local parsers = { "bash", "c", "cpp", "go", "html", "java", "javascript", "json", "lua", "markdown", "markdown_inline", "python", "rust", "tsx", "typescript", "typst" }
require'nvim-treesitter'.install(parsers)

vim.api.nvim_create_autocmd('FileType', {
	pattern = parsers,
	callback = function()
		vim.treesitter.start()
	end,
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = parsers,
	callback = function()
		vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		vim.wo[0][0].foldmethod = 'expr'
	end,
})
