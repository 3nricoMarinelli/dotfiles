-- Molten: Jupyter notebook interactive execution inside Neovim
-- Requires Python packages: pip install pynvim jupyter_client
-- Optional (for image output): pip install cairosvg plotly kaleido
--
-- Note: All keybindings are configured in python.lua and set per-buffer
-- when FileType is python or quarto. This file contains only core setup.

-- Basic display settings
vim.g.molten_auto_open_output = false
vim.g.molten_output_win_max_height = 20
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = true
vim.g.molten_wrap_output = true
vim.g.molten_image_provider = "none" -- set to "image.nvim" if image.nvim is installed
