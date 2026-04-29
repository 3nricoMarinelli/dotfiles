-- Gruvbox theme only - no switching allowed

local function setup_gruvbox()
	local ok, cs = pcall(require, "plugins.colorscheme")
	if not ok then
		return
	end
	cs.setup_gruvbox()
end

local function ensure_soft_gruvbox()
	if vim.g.colors_name ~= "gruvbox" then
		return
	end

	-- keep background transparent for gruvbox
	vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeSignColumn", { bg = "NONE" })
end

_G.load_theme = function()
	setup_gruvbox()
	vim.cmd("colorscheme gruvbox")
	require("lualine").setup({ options = { theme = "auto" } })
	ensure_soft_gruvbox()
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "gruvbox",
	callback = ensure_soft_gruvbox,
})
