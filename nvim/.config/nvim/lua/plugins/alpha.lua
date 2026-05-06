local alpha = require("alpha")
require("alpha.term")
local dashboard = require("alpha.themes.dashboard")

_G.alpha_open_tree_fullscreen = function()
  local alpha_buf = vim.api.nvim_get_current_buf()
  vim.g.__dashboard_opening_tree = true
  vim.cmd("Neotree filesystem reveal current")
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(alpha_buf) and vim.bo[alpha_buf].filetype == "alpha" then
      pcall(vim.api.nvim_buf_delete, alpha_buf, { force = true })
    end
  end)
  vim.defer_fn(function()
    vim.g.__dashboard_opening_tree = nil
  end, 500)
end

-- Dynamic git repo detection and onefetch command generation
_G.get_dashboard_command = function()
  -- Try to find git root from current working directory
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  local git_root = handle:read("*a"):gsub("\n", "")
  handle:close()

  if git_root ~= "" then
    -- We found a git repo, use onefetch with full path
    -- Use full path since terminal won't have shell PATH
    local onefetch_cmd = table.concat({
      "cd",
      git_root,
      "&&",
      "/opt/homebrew/bin/onefetch",
      "--true-color always",
      "--no-color-palette",
      "--number-of-authors 2",
      "--number-of-languages 5",
      "--disabled-fields description head dependencies contributors url commits churn lines-of-code license",
    }, " ")
    return onefetch_cmd
  else
    -- Fallback: show system info (if available) or message
    if vim.fn.executable("/opt/homebrew/bin/neofetch") == 1 then
      return "/opt/homebrew/bin/neofetch"
    else
      -- Last resort: simple message
      return "echo 'Open this editor in a git repository to see repository info'"
    end
  end
end

dashboard.section.header.opts.hl = "Question"

local onefetch_minimal_cmd = _G.get_dashboard_command()

dashboard.section.buttons.val = {
  dashboard.button("s", "󰚰  Restore", ":SessionLoadLast<CR>"),
  dashboard.button("t", "󰙅  Tree", ":lua alpha_open_tree_fullscreen()<CR>"),
  dashboard.button(
    "f",
    "󰱼  Filename Finder",
    ":lua pcall(require('utils.telescope-launcher').startup)<CR>"
  ),
  dashboard.button(
    "g",
    "󰱼  Grep Finder",
    ":lua pcall(require('utils.telescope-launcher').open_grep)<CR>"
  ),
  dashboard.button("q", "󰅙  Quit", ":q!<CR>"),
}

dashboard.section.footer.val = ""

dashboard.section.buttons.opts.hl = "Keyword"
if vim.fn.executable("onefetch") == 1 then
  dashboard.section.terminal.command = onefetch_minimal_cmd
  dashboard.section.terminal.width = 120
  dashboard.section.terminal.height = 22
  dashboard.opts.layout = {
    { type = "padding", val = 1 },
    dashboard.section.terminal,
    { type = "padding", val = 2 },
    dashboard.section.buttons,
  }
end
dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)

local alpha_term_group = vim.api.nvim_create_augroup("vimrc_alpha_term", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = alpha_term_group,
  pattern = "*",
  callback = function(ev)
    local title = vim.b[ev.buf].term_title
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if title ~= "alpha_terminal" and not name:match("onefetch") then
      return
    end
    vim.opt_local.scrollback = 1
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    for _, k in ipairs({
      "<ScrollWheelUp>",
      "<ScrollWheelDown>",
      "<PageUp>",
      "<PageDown>",
      "<C-y>",
      "<C-e>",
    }) do
      vim.keymap.set({ "n", "t" }, k, "<Nop>", { buffer = ev.buf, silent = true })
    end
  end,
})

-- Clean terminal output in alpha terminal (remove [Process exited X] messages)
-- Use both TermClose (cleanup) and TermLeave (suppress display)
vim.api.nvim_create_autocmd("TermClose", {
  group = alpha_term_group,
  pattern = "*",
  callback = function(ev)
    local title = vim.b[ev.buf].term_title
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if title ~= "alpha_terminal" and not name:match("onefetch") then
      return
    end

    -- Cleanup immediately on TermClose (before redraw)
    if vim.api.nvim_buf_is_valid(ev.buf) then
      local was_modifiable = vim.bo[ev.buf].modifiable
      vim.bo[ev.buf].modifiable = true

      local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      local new_lines = {}

      -- Filter out [Process exited messages
      for _, line in ipairs(lines) do
        if not line:match("%[Process exited") then
          table.insert(new_lines, line)
        end
      end

      -- Remove trailing empty lines
      while #new_lines > 0 and vim.trim(new_lines[#new_lines]) == "" do
        table.remove(new_lines)
      end

      -- Update immediately without defer
      if #new_lines ~= #lines then
        pcall(function()
          vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, new_lines)
        end)
      end

      vim.bo[ev.buf].modifiable = was_modifiable
    end
  end,
})
