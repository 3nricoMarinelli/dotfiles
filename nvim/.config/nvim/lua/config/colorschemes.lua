-- Theme registry for Zed editor themes and ports

local M = {}

M.items = {
  {
    repo = "hamzamogni/zed_onedark.nvim",
    name = "zed_onedark",
    schemes = { "zed_onedark" },
  },
  {
    repo = "anchietajunior/zedlight.nvim",
    name = "zedlight",
    schemes = { "zedlight" },
  },
  {
    repo = "53p3h2/kanagawa-zed.nvim",
    name = "kanagawa-zed",
    schemes = { "kanagawa-zed" },
  },
  {
    repo = "edis0n-zhang/andromeda.nvim",
    name = "andromeda",
    schemes = { "andromeda" },
  },
  {
    repo = "martinconic/macos-classic.nvim",
    name = "macos-classic",
    schemes = {
      "macos-classic",
      "macos-classic-dark",
      "macos-classic-dark_soft",
      "macos-classic-dark_graphite",
      "macos-classic-dark_slate",
      "macos-classic-light",
    },
  },
  {
    repo = "sale87/ultimate-dark-neo.nvim",
    name = "ultimate-dark-neo",
    schemes = { "ultimate-dark-neo" },
  },
  {
    repo = "randoneering/popping-and-locking.nvim",
    name = "popping_and_locking",
    schemes = { "popping_and_locking" },
  },
  {
    repo = "rdrachmanto/cisco-theme.nvim",
    name = "cisco",
    schemes = { "cisco" },
  },
  {
    repo = "Shatur/neovim-ayu",
    name = "ayu",
    schemes = { "ayu", "ayu-dark", "ayu-light", "ayu-mirage" },
  },
  {
    repo = "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    schemes = { "gruvbox" },
  },
}

function M.names()
  local names = {}
  for _, item in ipairs(M.items) do
    vim.list_extend(names, item.schemes)
  end
  return names
end

return M
