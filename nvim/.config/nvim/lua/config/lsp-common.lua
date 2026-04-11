-- Shared LSP helpers: capabilities + optional telescope fallbacks.

local M = {}

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_lsp_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  return capabilities
end

function M.has_telescope()
  return pcall(require, "telescope")
end

return M
