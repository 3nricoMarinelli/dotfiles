local M = {}

function M.project_root(bufnr)
  return vim.fs.root(bufnr or 0, {
    "CMakeLists.txt",
    "CMakeUserPresets.json",
    "vcpkg.json",
    ".git",
  }) or vim.fn.getcwd()
end

function M.setup()
  -- Nothing special needed for now
end

function M.start_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root = M.project_root(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "neocmakelsp" })
  if #clients > 0 then
    return
  end

  local capabilities = require("lsp").capabilities()
  vim.lsp.start({
    name = "neocmakelsp",
    cmd = { "neocmakelsp" },
    root_dir = root,
    capabilities = capabilities,
  }, { bufnr = bufnr })
end

return M
