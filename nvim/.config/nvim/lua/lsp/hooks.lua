local M = {}

local function setup_lsp_autocmds()
  -- C / C++
  local c_cpp_lsp_loaded = false
  local cmake_loaded = false
  local gtest_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(args)
      if not c_cpp_lsp_loaded then
        require("lsp.c-cpp").setup()
        c_cpp_lsp_loaded = true
      end
      require("lsp.c-cpp").start_lsp(args.buf)

      if not cmake_loaded then
        require("plugins.cmake").setup()
        cmake_loaded = true
      end
      if not gtest_loaded then
        require("plugins.gtest").setup()
        gtest_loaded = true
      end
    end,
  })

  -- Python
  local python_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
      local ext = vim.fn.expand("%:e")
      if ext ~= "py" and ext ~= "" and ext ~= "ipynb" then
        return
      end

      if not python_lsp_loaded then
        pcall(require, "lsp.python")
        python_lsp_loaded = true
      end
      pcall(require("lsp.python").start_lsp, args.buf)
    end,
  })

  -- Lua
  local lua_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function(args)
      if not lua_lsp_loaded then
        require("lsp.lua").setup()
        lua_lsp_loaded = true
      end
      require("lsp.lua").start_lsp(args.buf)
    end,
  })
end

M.setup = setup_lsp_autocmds
return M
