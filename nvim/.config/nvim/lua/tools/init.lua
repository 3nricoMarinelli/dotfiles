local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("CppIncludeFormatter", { clear = true })

	-- C/C++ include formatter
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = { "*.h", "*.hpp", "*.hh", "*.hxx", "*.c", "*.cc", "*.cpp", "*.cxx", "*.inl" },
		callback = function(args)
			local ft = vim.bo[args.buf].filetype
			if ft == "typst" then return end
			local ok, formatter = pcall(require, "tools.include_formatter")
			if ok then
				formatter.format(args.buf)
			end
		end,
	})

	-- :Skel command
	vim.api.nvim_create_user_command("Skel", function()
		require("tools.skeleton").insert()
	end, { desc = "Insert C++ file template/skeleton" })

	pcall(function()
		require("tools.cpp_extract").setup()
	end)
	pcall(function()
		require("tools.cpp_trivial_constructor").setup()
	end)
	pcall(function()
		require("tools.license").setup()
	end)
end

return M
