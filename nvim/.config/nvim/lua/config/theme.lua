-- theme choice is saved in a file for persistence on restart
-- could use a plugin instead, but hey, this is more fun
-- lualine theme gets stored separately due to possible naming differences

local theme_file = vim.fn.stdpath("config") .. "/lua/config/saved_theme"

local function setup_theme_defs()
	local ok, cs = pcall(require, "plugins.colorscheme")
	if not ok then
		return
	end
	cs.setup_catppuccin()
	cs.setup_gruvbox()
end

local function ensure_soft_catppuccin()
	if vim.g.colors_name ~= "catppuccin" then
		return
	end

	local ok, palette = pcall(function()
		return require("catppuccin.palettes").get_palette("frappe")
	end)
	if not ok or not palette then
		return
	end

	-- keep background transparent and soft, matching previous look
	vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = palette.base, bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { fg = palette.base, bg = "NONE" })
	vim.api.nvim_set_hl(0, "NeoTreeSignColumn", { bg = "NONE" })
end

_G.load_theme = function()
	setup_theme_defs()
	local file = io.open(theme_file, "r")
	if file then
		local colorscheme = file:read("*l")
		vim.cmd("colorscheme " .. colorscheme)
		require("lualine").setup({ options = { theme = "auto" } })
		file:close()
	end
	ensure_soft_catppuccin()
end

local themes = { --add more themes here, if installed
	{ "catppuccin", "catppuccin" },
	{ "gruvbox", "gruvbox" },
	{ "pywal16", "pywal16-nvim" },
}

local current_theme_index = 1

_G.switch_theme = function()
	setup_theme_defs()
	current_theme_index = current_theme_index % #themes + 1
	local colorscheme, lualine = unpack(themes[current_theme_index])
	vim.cmd("colorscheme " .. colorscheme)
	require("lualine").setup({ options = { theme = "auto" } })
	local file = io.open(theme_file, "w")
	if file then file:write(colorscheme .. "\n" .. lualine) file:close() end
	ensure_soft_catppuccin()
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "catppuccin",
	callback = ensure_soft_catppuccin,
})
