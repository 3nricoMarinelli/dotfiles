-- Neovim 0.12+ Inlay Hints Configuration
-- Provides type annotations and parameter names inline
-- Toggle with <leader>lh

local M = {}

-- Track inlay hints state per buffer
local inlay_hints_enabled = {}

--- Setup inlay hints for a specific buffer
--- @param bufnr number Buffer number
local function enable_inlay_hints(bufnr)
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    inlay_hints_enabled[bufnr] = true
  end
end

--- Disable inlay hints for a specific buffer
--- @param bufnr number Buffer number
local function disable_inlay_hints(bufnr)
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    inlay_hints_enabled[bufnr] = false
  end
end

--- Toggle inlay hints on current buffer
function M.toggle_inlay_hints()
  local bufnr = vim.api.nvim_get_current_buf()
  if inlay_hints_enabled[bufnr] then
    disable_inlay_hints(bufnr)
    vim.notify("Inlay hints disabled", vim.log.levels.INFO)
  else
    enable_inlay_hints(bufnr)
    vim.notify("Inlay hints enabled", vim.log.levels.INFO)
  end
end

--- Enable inlay hints for a buffer (used by on_attach)
function M.enable(bufnr)
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    inlay_hints_enabled[bufnr] = true
  end
end

--- Setup inlay hints (called from init.lua)
function M.setup()
  if not vim.lsp.inlay_hint then
    vim.notify("Inlay hints not available in this Neovim version", vim.log.levels.WARN)
    return
  end

  -- Enable inlay hints by default for new buffers
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("InlayHints", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local ft = vim.bo[bufnr].filetype
      local path = vim.api.nvim_buf_get_name(bufnr)
      local is_c_cpp = vim.tbl_contains({ "c", "cpp", "objc", "objcpp" }, ft)
        or path:match("%.h$")
        or path:match("%.hh$")
        or path:match("%.hpp$")
        or path:match("%.hxx$")
        or path:match("%.inl$")

      if not is_c_cpp then
        enable_inlay_hints(bufnr)
      end
    end,
  })
end

return M
