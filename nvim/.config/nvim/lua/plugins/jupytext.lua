-- Jupytext: transparent .ipynb ↔ Python conversion
-- Opens .ipynb files as regular .py files so all LSP features work.
-- The notebook is saved back as .ipynb on write.
--
-- Requires: pip install jupytext
--
-- Usage: just open a .ipynb file — it's converted automatically.
-- Cell boundaries are marked with: # %%
-- Filetype will be 'python', so pylsp, treesitter, nvim-lint all apply.

local jupytext_ok, jupytext = pcall(require, "jupytext")
if not jupytext_ok then return end

jupytext.setup({
    style            = "light",    -- minimal cell markers (# %%)
    output_extension = "auto",     -- keep original extension on save
    force_ft         = "python",   -- always treat as Python for LSP

    -- Per-format overrides
    custom_language_formatting = {
        python = {
            extension        = "py",
            style            = "percent",  -- use # %% cell markers (Jupyter percent format)
            force_ft         = "python",
        },
    },
})
