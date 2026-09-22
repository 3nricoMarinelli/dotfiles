-- C/C++ development & CMake build keybindings
-- Applied to C/C++ buffers (<leader>c* namespace)

local M = {}

function M.apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr].cpp_keymaps_applied then
    return
  end
  vim.b[bufnr].cpp_keymaps_applied = true

  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Which-key documentation
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.add({
      { "<leader>ch", desc = "switch header/source", buffer = bufnr },
      { "<leader>cs", desc = "insert skeleton (:Skel)", buffer = bufnr },
      { "<leader>cm", desc = "constructor (:CppTrvCtr)", buffer = bufnr },
      { "<leader>ce", desc = "extract method (:CppExtract)", buffer = bufnr },
      { "<leader>cE", desc = "extract class defs", buffer = bufnr },
      { "<leader>cc", desc = "cmake build", buffer = bufnr },
      { "<leader>cC", desc = "cmake clean & build", buffer = bufnr },
      { "<leader>ct", desc = "cmake test (ctest)", buffer = bufnr },
    })
  end

  -- C++ Navigation, Code Generation & Refactoring
  vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", vim.tbl_extend("force", opts, { desc = "Switch header/source" }))
  vim.keymap.set("n", "<leader>cs", "<cmd>Skel<CR>", vim.tbl_extend("force", opts, { desc = "Insert C++ skeleton" }))
  vim.keymap.set("n", "<leader>cm", "<cmd>CppTrvCtr<CR>", vim.tbl_extend("force", opts, { desc = "Generate constructor" }))
  vim.keymap.set("n", "<leader>ce", "<cmd>CppExtractFunctionDefinition<CR>", vim.tbl_extend("force", opts, { desc = "Extract function definition" }))
  vim.keymap.set("n", "<leader>cE", "<cmd>CppExtractDefinitions<CR>", vim.tbl_extend("force", opts, { desc = "Extract class definitions" }))

  -- CMake Build & Test Commands
  vim.keymap.set("n", "<leader>cc", function()
    vim.cmd("!cmake --build build 2>&1 | head -50")
  end, vim.tbl_extend("force", opts, { desc = "CMake build" }))

  vim.keymap.set("n", "<leader>cC", function()
    vim.cmd("!rm -rf build && mkdir -p build && cmake -B build && cmake --build build 2>&1 | head -50")
  end, vim.tbl_extend("force", opts, { desc = "CMake clean & build" }))

  vim.keymap.set("n", "<leader>ct", function()
    vim.cmd("!cmake --build build && ctest --output-on-failure 2>&1 | head -50")
  end, vim.tbl_extend("force", opts, { desc = "CMake test (ctest)" }))
end

return M
