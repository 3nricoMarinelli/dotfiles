-- lsp/hooks.lua
-- Contains the setup logic for language-specific LSP hooks and filetype autocommands.

local M = {}

-- Helper function to wrap the complex language setup (C++/Python/Rust/Typst/etc.)
-- and remove boilerplate from the main configuration file.
local function setup_lsp_autocmds()
  -- C++/{}
  local c_cpp_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(args)
      if not c_cpp_lsp_loaded then
        require("lsp.c-cpp")
        c_cpp_lsp_loaded = true
      end
      -- Start LSP for this buffer
      require("lsp.c-cpp").start_lsp(args.buf)

      -- Load CMake and GTest on first C/C++ file
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

      -- Guard against environmental errors during LSP setup
      if not python_lsp_loaded then
        pcall(require, "lsp.python")
        python_lsp_loaded = true
      end
      
      -- Attempt to start LSP, catching potential initialization errors
      pcall(require("lsp.python").start_lsp, args.buf)
    end,
  })

  -- Rust
  local rust_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function(args)
      if not rust_lsp_loaded then
        require("lsp.rust").setup()
        rust_lsp_loaded = true
      end
      -- rustaceanvim handles LSP automatically
    end,
  })

  -- Typst
  local typst_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function(args)
      if not typst_lsp_loaded then
        require("lsp.typst")
        typst_lsp_loaded = true
      end
      require("lsp.typst").start_lsp(args.buf)
    end,
  })

  -- MATLAB
  local matlab_lsp_loaded = false
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "matlab",
    callback = function(args)
      if not matlab_lsp_loaded then
        matlab_lsp_loaded = true
      end
      -- Use the main plugin module to handle LSP setup and activation
      require("matlab").start_lsp(args.buf) 
    end,
  })
end

M.setup = setup_lsp_autocmds
return M
