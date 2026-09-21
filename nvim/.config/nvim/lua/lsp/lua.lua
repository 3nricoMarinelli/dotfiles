local M = {}

function M.setup()
  local capabilities = require("lsp").capabilities()

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LuaLspAttach", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "lua_ls" then
        require("lsp").on_attach(client, args.buf)
      end
    end,
  })
end

function M.start_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "lua_ls" })
  if #clients > 0 then
    return
  end

  local capabilities = require("lsp").capabilities()
  local root = vim.fs.root(bufnr, { ".luarc.json", ".luacheckrc", "stylua.toml", ".git" }) or vim.fn.getcwd()

  local cmd = "lua-language-server"
  local mason_cmd = vim.fn.stdpath("data") .. "/mason/bin/lua-language-server"
  if vim.fn.executable(cmd) ~= 1 and vim.fn.executable(mason_cmd) == 1 then
    cmd = mason_cmd
  end

  if vim.fn.executable(cmd) ~= 1 then
    return
  end

  vim.lsp.start({
    name = "lua_ls",
    cmd = { cmd },
    root_dir = root,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
        telemetry = { enable = false },
      },
    },
  }, { bufnr = bufnr })
end

return M
