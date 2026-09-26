-- Helper for vim.keymap registration and which-key documentation

local M = {}
local pending_specs = {}

local function try_register_with_which_key(spec)
  -- Do not auto-require here: requiring would eagerly load the plugin.
  -- We only register immediately if which-key is already in memory.
  local wk = package.loaded["which-key"]
  if wk then
    wk.add(spec)
    return true
  end
  return false
end

function M.flush_which_key_specs()
  if #pending_specs == 0 then
    return
  end

  local wk_ok, wk = pcall(require, "which-key")
  if not wk_ok then
    return
  end

  for _, spec in ipairs(pending_specs) do
    wk.add(spec)
  end
  pending_specs = {}
end

function M.register(mode, key, action, desc, opts)
  opts = opts or {}

  local keymap_opts = vim.tbl_extend("force", {
    noremap = true,
    silent = true,
    desc = desc,
  }, opts.keymap or {})

  -- Register with vim.keymap
  vim.keymap.set(mode, key, action, keymap_opts)

  -- Register with which-key (queue if not loaded yet)
  local spec = { key, desc = desc }
  if mode ~= "n" then
    spec.mode = mode
  end
  if not try_register_with_which_key(spec) then
    table.insert(pending_specs, spec)
  end
end

local augroup = vim.api.nvim_create_augroup("KeymapHelperWhichKey", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "User" }, {
  group = augroup,
  pattern = { "*", "VeryLazy" },
  callback = function()
    M.flush_which_key_specs()
  end,
})

return M
