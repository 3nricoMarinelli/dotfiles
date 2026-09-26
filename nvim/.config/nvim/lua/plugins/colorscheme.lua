-- Plugin specifications for lazy.nvim dynamically generated from config/colorschemes
local colorschemes = require("config.colorschemes")

local specs = {}

for _, item in ipairs(colorschemes.items) do
  local spec = {
    item.repo,
    lazy = true,
    priority = 1000,
  }

  if item.name then
    spec.name = item.name
  end

  if item.repo == "ellisonleao/gruvbox.nvim" then
    spec.dependencies = { "rktjmp/lush.nvim" }
  end

  table.insert(specs, spec)
end

return specs
