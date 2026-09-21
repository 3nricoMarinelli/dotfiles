-- Molten: Jupyter notebook interactive execution inside Neovim
-- Requires Python packages: pip install pynvim jupyter_client
-- Optional (for image output): pip install cairosvg plotly kaleido
--
-- Note: All keybindings are configured in python.lua and set per-buffer
-- when FileType is python or quarto. This file contains only core setup.

-- Basic display settings (recommended by molten-nvim docs)
vim.g.molten_auto_open_output = false
vim.g.molten_output_win_max_height = 20
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = true
vim.g.molten_virt_text_max_lines = 16
vim.g.molten_wrap_output = true
vim.g.molten_cover_empty_lines = false
vim.g.molten_enter_output_behavior = "open_and_enter"

-- Auto-detect image provider
local has_image = pcall(require, "image")
if has_image then
  vim.g.molten_image_provider = "image.nvim"
else
  vim.g.molten_image_provider = "none"
end

-- External image viewer fallback (<leader>pv)
pcall(require, "plugins.molten-fallback-viewer")
