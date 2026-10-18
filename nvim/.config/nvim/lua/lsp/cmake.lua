local M = {}

-- Guard to prevent multiple setups
if _G.cmake_lsp_setup_done then
  return M
end

function M.find_binary()
  -- 1. Check system PATH
  local path = vim.fn.exepath("neocmakelsp")
  if path and path ~= "" and vim.fn.executable(path) == 1 then
    return path
  end

  -- 2. Check Mason bin directory
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/neocmakelsp"
  if vim.fn.executable(mason_bin) == 1 then
    return mason_bin
  end

  return nil
end

function M.project_root(bufnr)
  bufnr = bufnr or 0
  local root = vim.fs.root(bufnr, {
    ".neocmake.toml",
    "CMakePresets.json",
    "CMakeUserPresets.json",
    ".git",
    "build",
  })
  if not root then
    root = vim.fs.root(bufnr, { "CMakeLists.txt" })
  end
  return root or vim.fn.getcwd()
end

local function on_attach(client, bufnr)
  require("lsp").on_attach(client, bufnr)

  -- Apply CMake build keymaps (<leader>cc, <leader>cC, <leader>ct)
  local ok, cpp_maps = pcall(require, "config.mappings.cpp")
  if ok and cpp_maps.apply_cmake_build then
    cpp_maps.apply_cmake_build(bufnr)
  end
end

function M.setup()
  require("config.diagnostics").apply("lsp_clean_insert")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CmakeLspAttach", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "neocmake" then
        on_attach(client, args.buf)
      end
    end,
  })

  _G.cmake_lsp_setup_done = true
end

function M.start_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "neocmake" })
  if #clients > 0 then
    return
  end

  local bin = M.find_binary()
  if not bin then
    return
  end

  local root = M.project_root(bufnr)
  local capabilities = require("lsp").capabilities()

  vim.lsp.start({
    name = "neocmake",
    cmd = { bin, "stdio" },
    root_dir = root,
    capabilities = capabilities,
    init_options = {
      format = {
        enable = true,
      },
      scan_cmake_in_package = true,
    },
  }, { bufnr = bufnr })
end

return M
