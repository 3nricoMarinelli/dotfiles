-- image.nvim: Terminal image rendering for Molten REPL output
-- Supports ghostty (Sixel/Kitty), iTerm2, Kitty terminal
-- Renders inline figures from matplotlib, plotly, PIL, etc.
--
-- Backend: Kitty protocol (fallback to Sixel)
-- Sizing: Responsive (fits terminal width/height)
-- Integration: Molten captures figure → image.nvim renders inline

local ok, image = pcall(require, "image")
if not ok then
  return
end

image.setup({
  backend = "kitty",  -- ghostty supports Kitty protocol
  integrations = {
    markdown = {
      enabled = true,
      sizing_strategy = "fit_window",
    },
    html = {
      enabled = false,  -- Don't render HTML images (avoid Molten conflicts)
    },
  },
  -- Default pixel size to match common notebook defaults (VSCode/Colab-like)
  -- Terminal backends will scale to fit; these act as sensible fallbacks.
  max_width = 640,
  max_height = 480,
  window_overlap_clear_enabled = true,  -- Clear overlapping UI elements
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
})
