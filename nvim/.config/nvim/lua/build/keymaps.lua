-- Build system keybindings (C/C++ CMake)
-- Applied ONLY to build files: .c, .h, .cpp, .hpp, .cu, .cuh, .s
-- Via LSP on_attach in language files (only for clangd/build file types)
--
-- Currently supports:
--   - CMake build system (C/C++ projects)
--   - GoogleTest framework (C/C++ tests)
--
-- Build Keybindings (<leader>c* namespace):
--   <leader>cc  - Build current target
--   <leader>cC  - Clean build
--   <leader>ct  - Build and test (runs ctest)
--   <leader>cT  - GTest run under cursor
--   <leader>cr  - Run executable
--   <leader>cq  - Cancel build

local M = {}

function M.apply(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- ============================================================================
  -- WHICH-KEY DOCUMENTATION (register build group for this buffer)
  -- ============================================================================
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>c", group = "build", buffer = bufnr },
      { "<leader>cc", desc = "build target", buffer = bufnr },
      { "<leader>cC", desc = "clean build", buffer = bufnr },
      { "<leader>ct", desc = "build & test", buffer = bufnr },
      { "<leader>cT", desc = "gtest run", buffer = bufnr },
      { "<leader>cr", desc = "run executable", buffer = bufnr },
      { "<leader>cq", desc = "cancel build", buffer = bufnr },
    })
  end

  -- ============================================================================
  -- CMAKE BUILD COMMANDS
  -- ============================================================================

  -- Build current target (default: cmake --build build)
  vim.keymap.set("n", "<leader>cc", function()
    vim.cmd("!cmake --build build 2>&1 | head -50")
  end, opts)

  -- Clean build (default: rm -rf build && mkdir build)
  vim.keymap.set("n", "<leader>cC", function()
    vim.cmd("!rm -rf build && mkdir build && cmake -B build && cmake --build build 2>&1 | head -50")
  end, opts)

  -- Build and test (default: ctest --output-on-failure)
  vim.keymap.set("n", "<leader>ct", function()
    vim.cmd("!cmake --build build && ctest --output-on-failure 2>&1 | head -50")
  end, opts)

  -- GTest run under cursor
  vim.keymap.set("n", "<leader>cT", ":GTestRunUnderCursor<CR>", opts)

  -- Run executable (looks for main executable in build/)
  vim.keymap.set("n", "<leader>cr", function()
    -- Try to find and run the executable
    -- This is a simplified heuristic: looks for the first executable in build/
    vim.cmd("!find build -type f -executable -not -path '*/cmake*' | head -1 | xargs -I {} bash -c '{} 2>&1 | head -50'")
  end, opts)

  -- Cancel build (SIGINT to any running build process)
  vim.keymap.set("n", "<leader>cq", function()
    vim.cmd("!killall cmake make ninja 2>/dev/null || true")
  end, opts)
end

return M
