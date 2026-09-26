-- Theme manager with persistence, Zed themes, and tmux synchronization

local M = {}
local colorschemes = require("config.colorschemes")

local config = {
  themes = colorschemes.names(),
  default = "zed_onedark",
  fallback = "gruvbox",
  state_file = vim.fn.stdpath("state") .. "/theme.txt",
}

local function index_of(name)
  for i, theme in ipairs(config.themes) do
    if theme == name then
      return i
    end
  end
  return nil
end

local function persist(name)
  local dir = vim.fn.fnamemodify(config.state_file, ":h")
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ name }, config.state_file)
end

local function read_persisted()
  if vim.fn.filereadable(config.state_file) == 0 then
    return nil
  end

  local lines = vim.fn.readfile(config.state_file)
  if lines and #lines > 0 and lines[1] ~= "" then
    return lines[1]
  end
  return nil
end

local function setup_theme_hooks(name)
  if name == "gruvbox" then
    local ok, gruvbox = pcall(require, "gruvbox")
    if ok then
      gruvbox.setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
    end
  elseif name == "zed_onedark" then
    pcall(function()
      require("zed_onedark").setup()
    end)
  elseif name == "zedlight" then
    pcall(function()
      require("zedlight").setup()
    end)
  elseif name == "kanagawa-zed" then
    pcall(function()
      require("kanagawa-zed").setup()
    end)
  elseif name:find("^macos%-classic") then
    pcall(function()
      require("macos-classic").setup()
    end)
  elseif name == "cisco" then
    pcall(function()
      require("cisco").setup()
    end)
  elseif name:find("^ayu") then
    pcall(function()
      require("ayu").setup()
    end)
  elseif name == "popping_and_locking" then
    pcall(function()
      require("popping_and_locking").setup()
    end)
  end
end

local function ensure_transparency_or_ui(name)
  if name == "gruvbox" then
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeSignColumn", { bg = "NONE" })
  end

  -- Refresh lualine if active
  pcall(function()
    local lualine = require("lualine")
    lualine.setup({ options = { theme = "auto" } })
  end)
end

local function apply(name, opts)
  opts = opts or {}

  if not index_of(name) then
    vim.notify(("Unknown theme: %s"):format(name), vim.log.levels.ERROR)
    return false
  end

  setup_theme_hooks(name)

  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    if opts.silent ~= true then
      vim.notify(("Failed to load theme '%s'. Run :Lazy sync to install it."):format(name), vim.log.levels.WARN)
    end
    return false
  end

  ensure_transparency_or_ui(name)

  pcall(function()
    require("config.tmux_theme").sync(name)
  end)

  if opts.persist ~= false then
    persist(name)
  end

  if opts.notify then
    vim.notify(("Theme: %s"):format(name), vim.log.levels.INFO)
  end

  return true
end

function M.names()
  return vim.deepcopy(config.themes)
end

function M.current()
  return vim.g.colors_name
end

function M.set(name, opts)
  return apply(name, opts)
end

function M.cycle(step)
  step = step or 1

  local current = M.current()
  local current_index = index_of(current) or index_of(config.default) or 1
  local next_index = ((current_index - 1 + step) % #config.themes) + 1

  return apply(config.themes[next_index], { notify = true })
end

function M.select()
  vim.ui.select(config.themes, {
    prompt = "Select Zed Theme",
    format_item = function(item)
      if item == M.current() then
        return item .. " (current)"
      end
      return item
    end,
  }, function(choice)
    if choice then
      apply(choice, { notify = true })
    end
  end)
end

function M.load()
  local name = read_persisted() or config.default

  -- Attempt to apply persisted or default theme
  if apply(name, { persist = false, silent = true }) then
    return
  end

  -- Fallback to default if persisted was different
  if name ~= config.default and apply(config.default, { persist = false, silent = true }) then
    return
  end

  -- Fallback to installed fallback theme (e.g. gruvbox) before plugins are synced
  if apply(config.fallback, { persist = false, silent = true }) then
    return
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.api.nvim_create_user_command("Theme", function(command_opts)
    if command_opts.args == "" then
      M.select()
      return
    end

    M.set(command_opts.args, { notify = true })
  end, {
    nargs = "?",
    complete = function(arg_lead)
      return vim.tbl_filter(function(theme)
        return theme:find(arg_lead, 1, true) == 1
      end, config.themes)
    end,
    desc = "Select or set the active theme",
  })

  vim.api.nvim_create_user_command("ThemeNext", function()
    M.cycle(1)
  end, { desc = "Cycle to the next theme" })

  vim.api.nvim_create_user_command("ThemePrev", function()
    M.cycle(-1)
  end, { desc = "Cycle to the previous theme" })

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(args)
      ensure_transparency_or_ui(args.match)
      pcall(function()
        require("config.tmux_theme").sync(args.match)
      end)
    end,
  })

  M.load()
end

-- Backward compatibility for global load_theme()
_G.load_theme = function()
  M.load()
end

return M
