-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
return {
  keys = {
    { "<leader>mi", ":MoltenInit<CR>", desc = "Initialize Molten" },
    { "<leader>me", ":MoltenEvaluateOperator<CR>", desc = "Evaluate Operator", mode = "n" },
    { "<leader>ml", ":MoltenEvaluateLine<CR>", desc = "Evaluate Line" },
    { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Re-evaluate Cell" },
    { "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", desc = "Evaluate Visual", mode = "v" },
  },
}
