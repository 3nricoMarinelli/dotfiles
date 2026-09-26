-- File editing & commenting keymaps applied to editable file buffers

local M = {}
local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

local function is_editable_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bt = vim.bo[bufnr].buftype
  local ft = vim.bo[bufnr].filetype

  local ignored_buftypes = {
    nofile = true,
    quickfix = true,
    terminal = true,
    prompt = true,
    help = true,
  }

  local ignored_filetypes = {
    alpha = true,
    ["neo-tree"] = true,
    lazy = true,
    mason = true,
    TelescopePrompt = true,
    FTerm = true,
    whichkey = true,
    notify = true,
  }

  return not ignored_buftypes[bt] and not ignored_filetypes[ft]
end

function M.apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr].file_editing_keymaps_applied or not is_editable_file(bufnr) then
    return
  end
  vim.b[bufnr].file_editing_keymaps_applied = true

  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Line comment
  vim.keymap.set("n", "<leader>/", function()
    local ok, api = pcall(require, "Comment.api")
    if ok then
      api.toggle.linewise.current()
    else
      vim.cmd("normal gcc")
    end
  end, vim.tbl_extend("force", opts, { desc = "comment line" }))

  -- Block comment
  vim.keymap.set("n", "<leader>?", function()
    local ok, api = pcall(require, "Comment.api")
    if ok then
      api.toggle.blockwise.current()
    else
      vim.cmd("normal gbc")
    end
  end, vim.tbl_extend("force", opts, { desc = "comment block" }))

  -- Visual line comment
  vim.keymap.set("x", "<leader>/", function()
    local ok, api = pcall(require, "Comment.api")
    if ok then
      vim.api.nvim_feedkeys(esc, "nx", false)
      api.toggle.linewise(vim.fn.visualmode())
    else
      vim.api.nvim_feedkeys("gc", "m", false)
    end
  end, vim.tbl_extend("force", opts, { desc = "comment selection" }))

  -- Visual block comment
  vim.keymap.set("x", "<leader>?", function()
    local ok, api = pcall(require, "Comment.api")
    if ok then
      vim.api.nvim_feedkeys(esc, "nx", false)
      api.toggle.blockwise(vim.fn.visualmode())
    else
      vim.api.nvim_feedkeys("gb", "m", false)
    end
  end, vim.tbl_extend("force", opts, { desc = "comment block selection" }))

  -- Insert human authorship header
  vim.keymap.set("n", "<leader>cl", function()
    require("tools.license").insert_header()
  end, vim.tbl_extend("force", opts, { desc = "insert file header" }))

  -- Generate doc comment
  vim.keymap.set("n", "<leader>d", function()
    vim.fn["doge#generate"]()
  end, vim.tbl_extend("force", opts, { desc = "generate doc comment" }))

  -- File text editing
  vim.keymap.set("n", "<leader>R", ":%s/<C-r><C-w>/<C-r><C-w>/g<Left><Left>", vim.tbl_extend("force", opts, { desc = "search and replace word" }))
  vim.keymap.set("n", "<leader>r", "ve\"_dP", vim.tbl_extend("force", opts, { desc = "replace selection" }))
  vim.keymap.set("n", "<leader>x", "<cmd>BufferClose<CR>", vim.tbl_extend("force", opts, { desc = "close buffer" }))
  vim.keymap.set("n", "<leader>n", function()
    vim.wo.relativenumber = not vim.wo.relativenumber
    vim.wo.number = true
  end, vim.tbl_extend("force", opts, { desc = "toggle relative nums" }))
  vim.keymap.set("n", "<leader>W", ":set wrap!<CR>", vim.tbl_extend("force", opts, { desc = "toggle wrap" }))
end

function M.setup()
  local group = vim.api.nvim_create_augroup("FileEditingKeymaps", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType" }, {
    group = group,
    callback = function(ev)
      M.apply(ev.buf)
    end,
  })

  local cur = vim.api.nvim_get_current_buf()
  if is_editable_file(cur) then
    M.apply(cur)
  end
end

return M
