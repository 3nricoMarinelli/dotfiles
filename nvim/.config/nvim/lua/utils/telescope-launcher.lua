-- telescope-launcher: Wrapper around telescope for startup picker with Tab toggle
-- Lazy-loads Telescope on first use
-- Tab toggles between file name search and file content search
-- Preview pane takes 50% of screen horizontally

local M = {}

-- Main launcher: Start with Files picker
function M.startup()
	M.open_files()
end

-- Open Files picker with Tab toggle to Grep
function M.open_files()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope not yet loaded", vim.log.levels.WARN)
		return
	end

	local ok_actions, actions = pcall(require, "telescope.actions")
	if not ok_actions then
		vim.notify("telescope.actions not available", vim.log.levels.WARN)
		return
	end

	builtin.find_files({
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				width = 0.99,
				height = 0.99,
				preview_width = 0.5,
			},
		},
		attach_mappings = function(prompt_bufnr, map)
			map("i", "<Tab>", function()
				actions.close(prompt_bufnr)
				M.open_grep()
			end)
			return true
		end,
	})
end

-- Open Live Grep picker with Tab toggle back to Files
function M.open_grep()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope not yet loaded", vim.log.levels.WARN)
		return
	end

	local ok_actions, actions = pcall(require, "telescope.actions")
	if not ok_actions then
		vim.notify("telescope.actions not available", vim.log.levels.WARN)
		return
	end

	builtin.live_grep({
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				width = 0.99,
				height = 0.99,
				preview_width = 0.5,
			},
		},
		attach_mappings = function(prompt_bufnr, map)
			map("i", "<Tab>", function()
				actions.close(prompt_bufnr)
				M.open_files()
			end)
			return true
		end,
	})
end

return M
