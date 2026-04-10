-- fzf-launcher: Simple wrapper around fzf-lua for Files + Grep with Tab toggle
-- Provides seamless toggle between files and live_grep with Tab key
-- Prevents mode switching (regex vs fuzzy) by using Tab as primary toggle

local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

local M = {}

-- Main launcher: Start with Files picker
function M.startup()
	M.open_files()
end

-- Open Files picker with Tab toggle to Grep
function M.open_files()
	fzf.files({
		prompt = "Files> ",
		cwd = vim.fn.getcwd(),
		actions = {
			["default"] = actions.file_edit,
			-- Tab: Switch to Grep mode (without toggling search mode)
			["tab"] = function(selected, opts)
				M.open_grep()
			end,
		},
	})
end

-- Open Live Grep picker with Tab toggle back to Files
function M.open_grep()
	fzf.live_grep({
		prompt = "Grep> ",
		cwd = vim.fn.getcwd(),
		actions = {
			["default"] = actions.file_edit,
			-- Tab: Switch back to Files mode (without toggling search mode)
			["tab"] = function(selected, opts)
				M.open_files()
			end,
		},
	})
end

return M
