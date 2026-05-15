-- Unified LSP keybindings applied to all languages
-- Ensures consistent UX across C/C++, Python, Rust, Typst, etc.
--
-- Core LSP Keybindings (all languages, <leader>l* namespace):
--   <leader>ld   - Go to definition
--   <leader>lD   - Declarations
--   <leader>ln   - Rename symbol
--   <leader>lr   - References
--   <leader>li   - Implementations
--   <leader>lt   - Type definitions
--   <leader>lk   - Signature help
--   <leader>la   - Code actions
--   <leader>lx   - Diagnostics (Telescope)
--   <leader>lh   - Toggle inlay hints (Neovim 0.12+)
--   <leader>ll   - Lint list (only in Python, C/C++ - where linters are available)
--   <leader>lf   - Format toggle (only in supported formatters)
--
-- Universal LSP commands (language-agnostic):
--   K            - Hover documentation
--   [d / ]d      - Navigate diagnostics (prev/next)

local M = {}

function M.apply(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  
  -- Detect if current buffer has linting support
  local filetype = vim.bo[bufnr].filetype
  local has_linter = filetype == "python" or filetype == "c" or filetype == "cpp"

  -- ============================================================================
  -- WHICH-KEY DOCUMENTATION (register LSP group for this buffer)
  -- ============================================================================
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    local wk_entries = {
      { "<leader>l", group = "LSP", buffer = bufnr },
      { "<leader>ld", desc = "go definition", buffer = bufnr },
      { "<leader>lD", desc = "go declaration", buffer = bufnr },
      { "<leader>ln", desc = "rename symbol", buffer = bufnr },
      { "<leader>la", desc = "code action", buffer = bufnr },
      { "<leader>li", desc = "implementations", buffer = bufnr },
      { "<leader>lt", desc = "type definition", buffer = bufnr },
      { "<leader>lr", desc = "show references", buffer = bufnr },
      { "<leader>lx", desc = "list diagnostics", buffer = bufnr },
      { "<leader>lk", desc = "signature help", buffer = bufnr },
      { "<leader>lh", desc = "toggle hints", buffer = bufnr },
    }
    
    -- Add lint keybinding only for supported languages
    if has_linter then
      table.insert(wk_entries, { "<leader>ll", desc = "lint list", buffer = bufnr })
    end
    
    wk.add(wk_entries)
  end

  -- ============================================================================
  -- CORE LSP NAVIGATION (all <leader>l* commands)
  -- ============================================================================

  -- Definition
  vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)

  -- Declaration
  vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, opts)

  -- ============================================================================
  -- UNIVERSAL LSP COMMANDS (language-agnostic, work regardless of context)
  -- ============================================================================

  -- Hover Documentation
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Signature Help
  vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help, opts)

  -- ============================================================================
  -- REFACTORING & CODE ACTIONS
  -- ============================================================================

  -- Rename (single, consistent binding in <leader>l namespace)
  vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, opts)

  -- Code Actions (works across all LSPs)
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
  vim.keymap.set("v", "<leader>la", vim.lsp.buf.code_action, opts)

  -- ============================================================================
  -- DISCOVERY & NAVIGATION
  -- ============================================================================

  -- Implementations
  vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, opts)

  -- Type Definitions
  vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)

  -- References
  local has_telescope = pcall(require, "telescope")
  if has_telescope then
    vim.keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)
  else
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
  end

  -- ============================================================================
  -- DIAGNOSTICS
  -- ============================================================================

  -- Navigate Diagnostics
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  -- List Diagnostics (single, consistent binding in <leader>l namespace)
  if has_telescope then
    vim.keymap.set("n", "<leader>lx", "<cmd>Telescope diagnostics<CR>", opts)
  else
    vim.keymap.set("n", "<leader>lx", vim.diagnostic.setloclist, opts)
  end

  -- ============================================================================
  -- ADVANCED FEATURES (Neovim 0.12+)
  -- ============================================================================

  -- Hints Toggle (Neovim 0.12+)
  vim.keymap.set("n", "<leader>lh", function()
    require("lsp.hints").toggle_inlay_hints()
  end, opts)

  -- ============================================================================
  -- LINTING (only for supported languages with linters available)
  -- ============================================================================
  if has_linter then
    local has_telescope = pcall(require, "telescope")
    vim.keymap.set("n", "<leader>ll", function()
      if has_telescope then
        require("telescope.builtin").diagnostics({ bufnr = bufnr })
      else
        vim.diagnostic.setloclist()
      end
      vim.notify("Linting diagnostics (" .. filetype .. ")", vim.log.levels.INFO)
    end, opts)
  end
end

return M
