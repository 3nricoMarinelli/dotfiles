-- Colorscheme setup helpers

local M = {}

function M.setup_catppuccin()
	require("catppuccin").setup({
		flavour = "frappe",
		transparent_background = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
	})
end

function M.setup_gruvbox()
	local ok, gruvbox = pcall(require, "gruvbox")
	if not ok then
		return
	end

	gruvbox.setup({
		terminal_colors = true,
		undercurl = true,
		underline = true,
		bold = true,
		italic = {
			strings = true,
			emphasis = true,
			comments = true,
			operators = false,
			folds = true,
		},
		strikethrough = true,
		invert_selection = false,
		invert_signs = false,
		invert_tabline = false,
		inverse = true,
		contrast = "",
		palette_overrides = {},
		overrides = {},
		dim_inactive = false,
		transparent_mode = true,
	})
end

return M
