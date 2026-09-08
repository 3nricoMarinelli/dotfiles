-- C/C++ LSP Configuration (using vim.lsp.config API - Neovim 0.11+)
-- Superior clangd setup with clang-tidy for real-time linting
--
-- Required: clangd (brew install llvm)
-- Optional: .clang-tidy file in project root for custom rules
--
-- Linting:
--   - clang-tidy (via clangd) - real-time as you type
--   - cppcheck (via nvim-lint) - on save (see nvim-lint.lua)
--
-- LSP Keybindings (unified across all languages, see lsp/keymaps.lua):
--   <leader>ld   - Go to definition
--   <leader>lD   - Declarations
--   <leader>ln   - Rename symbol
--   <leader>la   - Code actions
--   <leader>li   - Implementations
--   <leader>lt   - Type definitions
--   <leader>lk   - Signature help
--   <leader>lr   - References
--   <leader>lx   - Diagnostics (Telescope)
--   K            - Hover documentation
--   [d / ]d      - Navigate diagnostics
--
-- DAP Keybindings (debugging, see dap/keymaps.lua):
--   <leader>Db   - Toggle breakpoint
--   <leader>Dc   - Continue / Start debugging
--   <leader>Do   - Step over
--   <leader>Di   - Step into
--   <leader>DO   - Step out
--   <leader>Dq   - Terminate session
--   <leader>Du   - Toggle DAP UI

local M = {}

function M.project_root(bufnr)
  return vim.fs.root(bufnr or 0, {
    "CMakeLists.txt",
    "CMakeUserPresets.json",
    "vcpkg.json",
    ".git",
  }) or vim.fn.getcwd()
end

function M.build_dir(root)
  local candidates = {
    root .. "/build-local",
    root .. "/build",
  }

  for _, dir in ipairs(candidates) do
    if vim.uv.fs_stat(dir .. "/compile_commands.json") then
      return dir
    end
  end

  -- Default for a project that has not been configured yet.
  return root .. "/build-local"
end

function M.clangd_cmd(root)
  return {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--pch-storage=memory",
    "--compile-commands-dir=" .. M.build_dir(root),
  }
end

function M.cmake_configure(root)
  local build_dir = root .. "/build-local"

  return {
    "cmake",
    "-S", root,
    "-B", build_dir,
    "-G", "Ninja",
    "-DCMAKE_BUILD_TYPE=Debug",
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
  }
end

function M.cmake_build(root)
  return {
    "cmake",
    "--build",
    root .. "/build-local",
  }
end

M.clangd = "clangd"
M.cmake_generator = "Ninja"
M.vcpkg_root = os.getenv("VCPKG_ROOT")
M.vcpkg_triplet = os.getenv("VCPKG_TRIPLET")

return M
