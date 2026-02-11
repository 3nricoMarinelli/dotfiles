-- CMake plugin configuration
-- Based on: https://codevion.github.io/#!vim/cpp2.md
-- Provides CMake build integration for C++ projects

local M = {}

function M.setup()
	-- Link compile_commands.json for better LSP support
	vim.g.cmake_link_compile_commands = 1
	
	-- Optional: Configure project root detection
	-- vim.g.cmake_root_markers = { '.git', 'compile_commands.json' }
	
	-- Optional: Set default build directory
	-- vim.g.cmake_build_dir = 'build'
end

return M
