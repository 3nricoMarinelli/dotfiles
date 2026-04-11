local alpha = require("alpha")
require("alpha.term")
local dashboard = require("alpha.themes.dashboard")

_G.alpha_open_tree_fullscreen = function()
	local alpha_buf = vim.api.nvim_get_current_buf()
	vim.g.__dashboard_opening_tree = true
	vim.cmd("Neotree filesystem reveal current")
	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(alpha_buf) and vim.bo[alpha_buf].filetype == "alpha" then
			pcall(vim.api.nvim_buf_delete, alpha_buf, { force = true })
		end
	end)
	vim.defer_fn(function()
		vim.g.__dashboard_opening_tree = nil
	end, 500)
end

dashboard.section.header.val =
	vim.fn.readfile(vim.fs.normalize("~/.config/nvim/lua/rc/files/dashboard_custom_header.txt"))
dashboard.section.header.opts.hl = "Question"

local onefetch_minimal_cmd = table.concat({
	"onefetch",
	"--true-color always",
	"--no-color-palette",
	"--number-of-authors 2",
	"--number-of-languages 5",
	"--disabled-fields description head dependencies contributors url commits churn lines-of-code license",
	"2>/dev/null",
}, " ")

dashboard.section.buttons.val = {
	dashboard.button("s", "󰚰  Restore", ":SessionLoadLast<CR>"),
	dashboard.button("t", "  Tree", ":lua alpha_open_tree_fullscreen()<CR>"),
	dashboard.button("f", "󰱼  Finder", ":lua pcall(require('utils.telescope-launcher').startup)<CR>"),
	dashboard.button("q", "󰅙  Quit", ":q!<CR>"),
}

dashboard.section.footer.val = ""

dashboard.section.buttons.opts.hl = "Keyword"
if vim.fn.executable("onefetch") == 1 then
	dashboard.section.terminal.command = onefetch_minimal_cmd
	dashboard.section.terminal.width = 120
	dashboard.section.terminal.height = 22
	dashboard.opts.layout = {
		{ type = "padding", val = 1 },
		dashboard.section.terminal,
		{ type = "padding", val = 2 },
		dashboard.section.buttons,
	}
end
dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)

local alpha_term_group = vim.api.nvim_create_augroup("vimrc_alpha_term", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
	group = alpha_term_group,
	pattern = "*",
	callback = function(ev)
		local title = vim.b[ev.buf].term_title
		local name = vim.api.nvim_buf_get_name(ev.buf)
		if title ~= "alpha_terminal" and not name:match("onefetch") then
			return
		end
		vim.opt_local.scrollback = 1
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		for _, k in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>", "<PageUp>", "<PageDown>", "<C-y>", "<C-e>" }) do
			vim.keymap.set({ "n", "t" }, k, "<Nop>", { buffer = ev.buf, silent = true })
		end
	end,
})

vim.api.nvim_create_autocmd("TermClose", {
	group = alpha_term_group,
	pattern = "*",
	callback = function(ev)
		local title = vim.b[ev.buf].term_title
		local name = vim.api.nvim_buf_get_name(ev.buf)
		if title ~= "alpha_terminal" and not name:match("onefetch") then
			return
		end
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(ev.buf) then
				return
			end
			local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
			for i = #lines, 1, -1 do
				if lines[i]:match("^%[Process exited %d+%]$") then
					vim.api.nvim_buf_set_lines(ev.buf, i - 1, i, false, {})
					break
				end
			end
		end)
	end,
})
