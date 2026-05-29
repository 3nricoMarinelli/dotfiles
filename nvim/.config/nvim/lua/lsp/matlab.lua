-- MATLAB LSP Configuration (native vim.lsp.config)
-- Uses MATLAB-language-server via Node.js

local M = {}

-- Guard to prevent multiple setups
if _G.matlab_lsp_setup_done then
  return M
end

local function notify_missing_exe()
  if _G.matlab_lsp_missing_exe_notified then
    return
  end

  vim.notify(
    "matlab-language-server entrypoint not found",
    vim.log.levels.WARN
  )
  _G.matlab_lsp_missing_exe_notified = true
end

local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  -- Apply unified LSP setup from centralized config
  require("lsp").on_attach(client, bufnr)
end

function M.setup()
  require("config.diagnostics").apply("lsp_clean_insert")

  local capabilities = require("lsp").capabilities()

  local entrypoint = vim.fs.joinpath(vim.env.MATLAB_APP_PATH, "matlabls/out/index.js")
  if vim.fn.filereadable(entrypoint) ~= 1 then
    notify_missing_exe()
    return
  end

  M.lsp_config = {
    name = "matlab_ls",
    cmd = { "node", entrypoint, "--stdio" },
    filetypes = { "matlab" },
    capabilities = capabilities,
    settings = {
      MATLAB = {
        installPath = vim.fs.joinpath(vim.env.MATLAB_APP_PATH, vim.env.MATLAB_VERSION),
      },
    },
    single_file_support = true,
    on_attach = on_attach,
  }

  vim.lsp.config("matlab_ls",  M.lsp_config)
  vim.lsp.enable("matlab_ls")

  _G.matlab_lsp_setup_done = true
end

function M.start_lsp(bufnr)
  if not M.lsp_config then
    vim.notify("MATLAB LSP not configured, run setup() first", vim.log.levels.ERROR)
    return
  end

  local config = vim.deepcopy(M.lsp_config)

  local root = vim.fs.root(bufnr, { "matlab.prj", ".git" })
  if not root and config.single_file_support then
    root = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  end

  if root then
    config.root_dir = root
    vim.lsp.start(config, { bufnr = bufnr })
  else
    vim.notify("Could not determine root directory for MATLAB LSP", vim.log.levels.WARN)
  end
end

return M
