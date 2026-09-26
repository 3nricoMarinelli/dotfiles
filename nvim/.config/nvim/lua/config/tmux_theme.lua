-- Synchronizes Neovim theme palettes with tmux statusline and window borders

local M = {}

local palettes = {
  gruvbox = {
    bg = "#1d2021",
    fg = "#ebdbb2",
    accent = "#fabd2f",
    active_bg = "#3c3836",
    active_fg = "#fabd2f",
    inactive_fg = "#928374",
    border_active = "#fabd2f",
    border_inactive = "#504945",
  },
  zed_onedark = {
    bg = "#21252b",
    fg = "#abb2bf",
    accent = "#61afef",
    active_bg = "#2c313a",
    active_fg = "#61afef",
    inactive_fg = "#5c6370",
    border_active = "#61afef",
    border_inactive = "#3e4452",
  },
  zedlight = {
    bg = "#f0f0f0",
    fg = "#383a42",
    accent = "#4078f2",
    active_bg = "#e5e5e6",
    active_fg = "#4078f2",
    inactive_fg = "#a0a1a7",
    border_active = "#4078f2",
    border_inactive = "#d0d0d0",
  },
  ["kanagawa-zed"] = {
    bg = "#16161e",
    fg = "#dcd7ba",
    accent = "#7e9cd8",
    active_bg = "#223249",
    active_fg = "#98bb6c",
    inactive_fg = "#727169",
    border_active = "#7e9cd8",
    border_inactive = "#2a2a37",
  },
  andromeda = {
    bg = "#1e222a",
    fg = "#d5ced9",
    accent = "#00e8c6",
    active_bg = "#2b303c",
    active_fg = "#00e8c6",
    inactive_fg = "#746f77",
    border_active = "#00e8c6",
    border_inactive = "#3b4048",
  },
  ["macos-classic-dark"] = {
    bg = "#141414",
    fg = "#f5f5f7",
    accent = "#007aff",
    active_bg = "#2c2c2e",
    active_fg = "#007aff",
    inactive_fg = "#8e8e93",
    border_active = "#007aff",
    border_inactive = "#38383a",
  },
  ["macos-classic-dark_soft"] = {
    bg = "#1c1c1e",
    fg = "#f5f5f7",
    accent = "#0a84ff",
    active_bg = "#2c2c2e",
    active_fg = "#0a84ff",
    inactive_fg = "#8e8e93",
    border_active = "#0a84ff",
    border_inactive = "#38383a",
  },
  ["macos-classic-dark_graphite"] = {
    bg = "#191919",
    fg = "#e5e5e7",
    accent = "#8e8e93",
    active_bg = "#2c2c2e",
    active_fg = "#f5f5f7",
    inactive_fg = "#636366",
    border_active = "#8e8e93",
    border_inactive = "#38383a",
  },
  ["macos-classic-dark_slate"] = {
    bg = "#16181a",
    fg = "#e1e4ea",
    accent = "#5ac8fa",
    active_bg = "#24272e",
    active_fg = "#5ac8fa",
    inactive_fg = "#717886",
    border_active = "#5ac8fa",
    border_inactive = "#2c313a",
  },
  ["macos-classic"] = {
    bg = "#f5f5f7",
    fg = "#1d1d1f",
    accent = "#0071e3",
    active_bg = "#e5e5ea",
    active_fg = "#0071e3",
    inactive_fg = "#86868b",
    border_active = "#0071e3",
    border_inactive = "#d1d1d6",
  },
  ["macos-classic-light"] = {
    bg = "#f5f5f7",
    fg = "#1d1d1f",
    accent = "#0071e3",
    active_bg = "#e5e5ea",
    active_fg = "#0071e3",
    inactive_fg = "#86868b",
    border_active = "#0071e3",
    border_inactive = "#d1d1d6",
  },
  ["ultimate-dark-neo"] = {
    bg = "#0c0c0c",
    fg = "#e0e0e0",
    accent = "#58a6ff",
    active_bg = "#222222",
    active_fg = "#58a6ff",
    inactive_fg = "#6e7681",
    border_active = "#58a6ff",
    border_inactive = "#30363d",
  },
  popping_and_locking = {
    bg = "#120e24",
    fg = "#e0e0e8",
    accent = "#e0007b",
    active_bg = "#292147",
    active_fg = "#00ffff",
    inactive_fg = "#6c688c",
    border_active = "#e0007b",
    border_inactive = "#3b325c",
  },
  cisco = {
    bg = "#14171a",
    fg = "#c9d1d9",
    accent = "#00bceb",
    active_bg = "#293036",
    active_fg = "#00bceb",
    inactive_fg = "#586069",
    border_active = "#00bceb",
    border_inactive = "#30363d",
  },
  ayu = {
    bg = "#05080c",
    fg = "#b3b1ad",
    accent = "#ff9940",
    active_bg = "#191f28",
    active_fg = "#ff9940",
    inactive_fg = "#626a73",
    border_active = "#ff9940",
    border_inactive = "#191f28",
  },
  ["ayu-dark"] = {
    bg = "#05080c",
    fg = "#b3b1ad",
    accent = "#ff9940",
    active_bg = "#191f28",
    active_fg = "#ff9940",
    inactive_fg = "#626a73",
    border_active = "#ff9940",
    border_inactive = "#191f28",
  },
  ["ayu-mirage"] = {
    bg = "#171b24",
    fg = "#cbccc6",
    accent = "#ffcc66",
    active_bg = "#282e3f",
    active_fg = "#ffcc66",
    inactive_fg = "#707a8c",
    border_active = "#ffcc66",
    border_inactive = "#282e3f",
  },
  ["ayu-light"] = {
    bg = "#f0f0f0",
    fg = "#5c6166",
    accent = "#ff9940",
    active_bg = "#e7e8eb",
    active_fg = "#ff9940",
    inactive_fg = "#8a9199",
    border_active = "#ff9940",
    border_inactive = "#d5d6db",
  },
}

local function extract_hl(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if hl and hl[attr] then
    return string.format("#%06x", hl[attr])
  end
  return nil
end

local function get_palette(theme_name)
  if palettes[theme_name] then
    return palettes[theme_name]
  end

  local bg = extract_hl("StatusLine", "bg") or extract_hl("Normal", "bg") or "#1f232a"
  local fg = extract_hl("StatusLine", "fg") or extract_hl("Normal", "fg") or "#abb2bf"
  local accent = extract_hl("Keyword", "fg") or extract_hl("Function", "fg") or "#61afef"
  local active_bg = extract_hl("Visual", "bg") or extract_hl("CursorLine", "bg") or "#2c313a"
  local inactive_fg = extract_hl("Comment", "fg") or "#5c6370"
  local border_active = accent
  local border_inactive = extract_hl("WinSeparator", "fg") or extract_hl("FloatBorder", "fg") or active_bg

  return {
    bg = bg,
    fg = fg,
    accent = accent,
    active_bg = active_bg,
    active_fg = accent,
    inactive_fg = inactive_fg,
    border_active = border_active,
    border_inactive = border_inactive,
  }
end

function M.sync(theme_name)
  local p = get_palette(theme_name)
  local conf_path = vim.fn.expand("~/.local/state/tmux/current_theme.conf")
  vim.fn.mkdir(vim.fn.fnamemodify(conf_path, ":h"), "p")

  local lines = {
    "# Auto-synced tmux theme from Neovim: " .. theme_name,
    "set -g status \"on\"",
    "set -g status-justify \"left\"",
    "set -g status-position \"bottom\"",
    string.format("set -g status-style \"bg=%s,fg=%s\"", p.bg, p.fg),
    string.format("set -g pane-border-style \"fg=%s\"", p.border_inactive),
    string.format("set -g pane-active-border-style \"fg=%s\"", p.border_active),
    string.format("set -g display-panes-colour \"%s\"", p.border_inactive),
    string.format("set -g display-panes-active-colour \"%s\"", p.border_active),
    string.format("set -g message-style \"bg=%s,fg=%s,bold\"", p.active_bg, p.active_fg),
    string.format("set -g message-command-style \"bg=%s,fg=%s\"", p.active_bg, p.fg),
    string.format("set -g mode-style \"bg=%s,fg=%s\"", p.accent, p.bg),
    "set -g window-status-separator \"\"",
    string.format("set -g window-status-style \"bg=%s,fg=%s\"", p.bg, p.inactive_fg),
    string.format("set -g window-status-current-style \"bg=%s,fg=%s,bold\"", p.active_bg, p.active_fg),
    string.format("set -g window-status-activity-style \"bg=%s,fg=%s\"", p.bg, p.accent),
    "set -g status-left-length \"100\"",
    "set -g status-right-length \"100\"",
    string.format("set -g status-left \"#[fg=%s,bg=%s,bold] #S #[fg=%s,bg=%s,nobold] \"", p.bg, p.accent, p.accent, p.bg),
    string.format("set -g window-status-format \"#[fg=%s,bg=%s]  #I:#W  \"", p.inactive_fg, p.bg),
    string.format("set -g window-status-current-format \"#[fg=%s,bg=%s]#[fg=%s,bg=%s,bold] #I:#W#{?window_zoomed_flag,*,} #[fg=%s,bg=%s,nobold]\"", p.bg, p.active_bg, p.active_fg, p.active_bg, p.active_bg, p.bg),
    string.format("set -g status-right \"#[fg=%s,bg=%s]#[fg=%s,bg=%s] %%Y-%%m-%%d  %%H:%%M #[fg=%s,bg=%s]#[fg=%s,bg=%s,bold] #h \"", p.active_bg, p.bg, p.inactive_fg, p.active_bg, p.accent, p.active_bg, p.bg, p.accent),
  }

  vim.fn.writefile(lines, conf_path)

  local tmux_bin = vim.fn.exepath("tmux")
  if tmux_bin == "" and vim.fn.executable("/opt/homebrew/bin/tmux") == 1 then
    tmux_bin = "/opt/homebrew/bin/tmux"
  end

  if tmux_bin ~= "" then
    vim.fn.jobstart({ tmux_bin, "source-file", conf_path }, {
      on_exit = function()
        vim.fn.jobstart({ tmux_bin, "refresh-client", "-S" })
      end,
    })
  end
end

return M
