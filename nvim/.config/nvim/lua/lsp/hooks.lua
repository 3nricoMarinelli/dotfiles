local M = {}

local function setup_lsp_autocmds()
  -- C / C++
  local c_cpp_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(args)
      if not c_cpp_lsp_loaded then
        require("lsp.c-cpp").setup()
        c_cpp_lsp_loaded = true
      end
      require("lsp.c-cpp").start_lsp(args.buf)

      require("build.keymaps").apply(args.buf)
      require("dap.keymaps").apply(args.buf)
    end,
  })

  -- Python & Quarto / Jupyter
  local python_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python", "quarto" },
    callback = function(args)
      require("config.mappings.python").apply(args.buf)

      local ext = vim.fn.expand("%:e")
      if ext ~= "py" and ext ~= "" and ext ~= "ipynb" then
        return
      end

      if not python_lsp_loaded then
        local ok, python_module = pcall(require, "lsp.python")
        if ok then
          python_module.setup(args.buf)
          python_lsp_loaded = true
        end
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
