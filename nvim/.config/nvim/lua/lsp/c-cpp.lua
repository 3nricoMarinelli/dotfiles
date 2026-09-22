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
    "--query-driver=/usr/bin/c++,/usr/bin/g++,/usr/bin/clang++,/usr/bin/gcc,/opt/homebrew/opt/llvm/bin/clang++",
    "--compile-commands-dir=" .. M.build_dir(root),
  }
end

-- Filter known Qt/clangd unsupported flag warning
local qt_clangd_flag_pattern = "^Unknown argument:%s*['\"]?%-mno%-direct%-extern%-access['\"]?"
local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == "clangd" and result and result.diagnostics then
    result = vim.deepcopy(result)
    result.diagnostics = vim.tbl_filter(function(diagnostic)
      local message = diagnostic.message or ""
      return not message:match(qt_clangd_flag_pattern)
    end, result.diagnostics)
  end

  return default_publish_diagnostics(err, result, ctx, config)
end

local function on_attach(client, bufnr)
  require("lsp").on_attach(client, bufnr)
  require("dap.keymaps").apply(bufnr)
  require("build.keymaps").apply(bufnr)
end

function M.switch_source_header(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
  if not client then
    vim.notify("clangd LSP is not attached to this buffer", vim.log.levels.WARN)
    return
  end
  local params = { uri = vim.uri_from_bufnr(bufnr) }
  client.request("textDocument/switchSourceHeader", params, function(err, result)
    if err then
      vim.notify("clangd error: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not result or result == "" then
      vim.notify("No corresponding header/source file found", vim.log.levels.WARN)
      return
    end
    vim.api.nvim_command("edit " .. vim.uri_to_fname(result))
  end, bufnr)
end

function M.setup()
  vim.api.nvim_create_user_command("ClangdSwitchSourceHeader", function()
    M.switch_source_header()
  end, { desc = "Switch between C/C++ header and source" })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("ClangdLspAttach", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "clangd" then
        on_attach(client, args.buf)
      end
    end,
  })
end

function M.start_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root = M.project_root(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })
  if #clients > 0 then
    return
  end

  local capabilities = require("lsp").capabilities()
  vim.lsp.start({
    name = "clangd",
    cmd = M.clangd_cmd(root),
    root_dir = root,
    capabilities = capabilities,
  }, { bufnr = bufnr })
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
