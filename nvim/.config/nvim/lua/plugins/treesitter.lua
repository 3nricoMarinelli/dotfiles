-- Use default install_dir, but ensure it's in runtimepath for parser loading
local site_dir = vim.fn.stdpath('data') .. '/site'
local rtp = vim.opt.runtimepath:get()
local in_rtp = false
for _, p in ipairs(rtp) do
    if p == site_dir then
        in_rtp = true
        break
    end
end
if vim.fn.isdirectory(site_dir) == 1 and not in_rtp then
    vim.opt.runtimepath:prepend(site_dir)
end

require'nvim-treesitter'.setup {
    install_dir = site_dir,
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
