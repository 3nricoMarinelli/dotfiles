-- DAP (Debug Adapter Protocol) initialization
-- Sets up nvim-dap with UI, virtual text, and per-language configuration
--
-- Requires:
--   - nvim-dap (main plugin)
--   - nvim-dap-ui (optional, for UI)
--   - nvim-dap-virtual-text (optional, for inline variable display)
--
-- Usage:
--   require("dap.init").setup()        -- Called automatically on plugin load
--   require("dap.keymaps").apply(bufnr)  -- Called per-buffer by language LSP files

local M = {}

function M.setup()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    return
  end

  local dapui_ok, dapui = pcall(require, "dapui")
  local dap_vtext_ok = pcall(require, "nvim-dap-virtual-text")

  -- ============================================================================
  -- BREAKPOINT SIGNS (UI indicators for breakpoints) - safe to do early
  -- ============================================================================
  vim.fn.sign_define("DapBreakpoint", {
    text = "",
    texthl = "DiagnosticSignError",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapBreakpointRejected", {
    text = "",
    texthl = "DiagnosticSignError",
    linehl = "",
    numhl = "",
  })
  vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DiagnosticSignWarn",
    linehl = "Visual",
    numhl = "DiagnosticSignWarn",
  })

  -- ============================================================================
  -- DAP UI AUTO-OPEN (manual listener registration)
  -- Skip dapui.setup() - let Lazy handle it. Just register our listeners manually.
  -- ============================================================================
  if dapui_ok then
    -- Register listeners with graceful error handling
    -- Defer by 200ms to ensure dap.listeners exists
    vim.defer_fn(function()
      if dap.listeners and type(dap.listeners) == "table" then
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end
    end, 200) -- Defer by 200ms for safety
  end
  -- ============================================================================
  -- C / C++ / Rust DAP CONFIGURATION
  -- ============================================================================
  local uv = vim.uv or vim.loop

  local function file_exists(path)
    return path and uv.fs_stat(path) ~= nil
  end

  local function is_executable(path)
    return file_exists(path) and vim.fn.executable(path) == 1
  end

  local function workspace_root()
    local current = vim.api.nvim_buf_get_name(0)
    local root_markers = {
      ".git",
      "compile_commands.json",
      "CMakeLists.txt",
      "Cargo.toml",
      "Makefile",
    }

    local root = vim.fs.dirname(vim.fs.find(root_markers, {
      path = current ~= "" and current or vim.fn.getcwd(),
      upward = true,
    })[1] or "")

    return root ~= "" and root or vim.fn.getcwd()
  end

  local function pick_cpp_binary()
    local cwd = workspace_root()
    local current = vim.api.nvim_buf_get_name(0)
    local stem = vim.fn.fnamemodify(current, ":t:r")
    local candidates = {
      cwd .. "/" .. stem,
      cwd .. "/build/" .. stem,
      cwd .. "/build-local/" .. stem,
      cwd .. "/bin/" .. stem,
      cwd .. "/build/debug/" .. stem,
      cwd .. "/build/Debug/" .. stem,
      cwd .. "/out/" .. stem,
    }

    for _, candidate in ipairs(candidates) do
      if is_executable(candidate) then
        vim.notify("DAP launching " .. candidate, vim.log.levels.INFO)
        return candidate
      end
    end

    local picked = vim.fn.input("Path to executable: ", cwd .. "/", "file")
    if picked == "" then
      vim.notify("DAP launch cancelled: no executable selected", vim.log.levels.WARN)
      return nil
    end
    if not is_executable(picked) then
      vim.notify("DAP launch aborted: not executable: " .. picked, vim.log.levels.ERROR)
      return nil
    end
    return picked
  end

  local function split_args(input)
    local args = {}
    for arg in string.gmatch(input, "%S+") do
      table.insert(args, arg)
    end
    return args
  end

  local function prompt_args()
    return split_args(vim.fn.input("Program arguments: "))
  end

  local lldb_dap = vim.fn.exepath("lldb-dap")
  local codelldb = vim.fn.exepath("codelldb")
  dap.adapters = dap.adapters or {}
  dap.configurations = dap.configurations or {}

  if lldb_dap ~= "" then
    dap.adapters.lldb = {
      type = "executable",
      command = lldb_dap,
      name = "lldb",
    }
  elseif codelldb ~= "" then
    dap.adapters.lldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb,
        args = { "--port", "${port}" },
      },
    }
  end

  local cpp_configurations = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = pick_cpp_binary,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "Launch with args",
      type = "lldb",
      request = "launch",
      program = pick_cpp_binary,
      args = prompt_args,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "Attach to process",
      type = "lldb",
      request = "attach",
      pid = function()
        local ok, dap_utils = pcall(require, "dap.utils")
        return ok and dap_utils.pick_process() or nil
      end,
      cwd = "${workspaceFolder}",
    },
  }

  dap.configurations.cpp = cpp_configurations
  dap.configurations.c = cpp_configurations
  dap.configurations.rust = cpp_configurations
end

return M
