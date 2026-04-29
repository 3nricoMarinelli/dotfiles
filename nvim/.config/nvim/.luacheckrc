-- Luacheck configuration for Neovim Lua config

globals = {
  "vim",
  "load_theme",
}

read_globals = {
  "vim",
}

max_line_length = false

ignore = {
  "631", -- line too long
  "212", -- unused argument
  "213", -- unused loop variable
  "122", -- setting read-only field (vim opt/global patterns)
}

self = false
