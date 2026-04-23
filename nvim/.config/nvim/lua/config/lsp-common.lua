-- Shared LSP helpers: capabilities + optional telescope fallbacks.
-- Window handlers configured for split view instead of floating windows.

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

-- Configure LSP handlers to use split view instead of floating windows
function M.setup_handlers()
  -- Helper function to jump to location in split view
  local function goto_location_in_split(location)
    if not location then return end
    
    local uri = location.uri
    local range = location.range
    local line = range.start.line
    local col = range.start.character
    
    -- Open buffer
    local bufnr = vim.uri_to_bufnr(uri)
    vim.cmd("split")
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { line + 1, col })
  end

  -- Override hover handler to use split view
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    if err or not result then return end
    
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    
    -- Show in split
    vim.cmd("split")
    vim.api.nvim_set_current_buf(buf)
  end

  -- Helper to handle location-based requests (definition, declaration, etc)
  local function location_handler(err, result, ctx, config)
    if err or not result then return end
    
    local items = vim.islist(result) and result or { result }
    if #items == 0 then return end
    
    goto_location_in_split(items[1])
  end

  -- Use same handler for definition and declaration (no redundancy)
  vim.lsp.handlers["textDocument/definition"] = location_handler
  vim.lsp.handlers["textDocument/declaration"] = location_handler
  vim.lsp.handlers["textDocument/typeDefinition"] = location_handler
  vim.lsp.handlers["textDocument/implementation"] = location_handler

  -- Override references handler (uses Telescope if available)
  vim.lsp.handlers["textDocument/references"] = function(err, result, ctx, config)
    if err or not result or #result == 0 then return end
    
    local has_telescope = pcall(require, "telescope")
    if has_telescope then
      require("telescope.builtin").lsp_references()
    else
      -- Fallback: open first reference in split
      goto_location_in_split(result[1])
    end
  end
end

return M
