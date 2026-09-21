-- Fallback external viewer for Molten images
-- Use when terminal doesn't support image embedding
-- Triggered by <leader>pv (manual override always available)

local M = {}

-- Extract and open image from Molten cell output
-- Searches Molten cache (~/.cache/nvim-molten/) for latest image
-- Opens in macOS Preview for inspection/zoom/export
local function open_image_externally()
  local temp_dir = os.getenv("HOME") .. "/.cache/nvim-molten"
  os.execute("mkdir -p " .. vim.fn.shellescape(temp_dir))

  -- Search for latest image in Molten cache (by modification time)
  local latest_image = vim.fn.system(
    "ls -t " .. vim.fn.shellescape(temp_dir) .. "/*.{png,jpg,jpeg,svg} 2>/dev/null | head -1"
  ):gsub("\n", "")

  if latest_image ~= "" and vim.fn.filereadable(latest_image) == 1 then
    vim.fn.system("open -a Preview " .. vim.fn.shellescape(latest_image))
    vim.notify("📸 Opened in Preview: " .. vim.fn.fnamemodify(latest_image, ":t"), vim.log.levels.INFO)
  else
    vim.notify("❌ No image found in Molten cache. Run a cell with figure output first.", vim.log.levels.WARN)
  end
end

-- Register keybinding on Python filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "quarto" },
  callback = function(ev)
    vim.keymap.set(
      "n",
      "<leader>pv",
      open_image_externally,
      { noremap = true, silent = true, buffer = ev.buf, desc = "Molten: View image externally" }
    )
  end,
})

return M
