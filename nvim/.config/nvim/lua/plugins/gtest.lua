-- GoogleTest plugin configuration
-- Based on: https://codevion.github.io/#!vim/cpp2.md
-- Provides test running integration for C++ projects using GoogleTest

local M = {}

function M.setup()
	-- Set the default test executable path
	-- You can override this per-project with :GTestCmd path/to/test/executable
	-- Or set it in your project-specific vimrc
	-- vim.g['gtest#gtest_command'] = "build/tests/my_tests"
	
	-- Optionally configure update time for test results
	-- vim.g['gtest#update_on_write'] = 1
end

return M
