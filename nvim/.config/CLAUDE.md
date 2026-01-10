# Neovim Configuration Improvements

## 2025-11-12: Jupyter Notebook Support with Molten

### Summary
Set up complete Jupyter notebook editing environment in Neovim with interactive code execution.

### Changes Made

1. **Fixed tmux configuration**
   - Added `allow-passthrough on` to `~/.tmux.conf` for image.nvim support
   - Enabled inline image rendering in terminal

2. **Installed Python dependencies**
   - Core: `pynvim`, `jupyter_client`, `ipykernel`
   - Optional: `cairosvg`, `pnglatex`, `plotly`, `kaleido`, `pyperclip`, `nbformat`
   - Notebook conversion: `jupytext`

3. **Configured molten-nvim**
   - Location: `lua/plugins/notebook.lua`
   - Keybindings (all use `<leader>` = Space):
     - `Space + mi` - Initialize Molten kernel
     - `Space + rl` - Evaluate line
     - `Space + rr` - Re-evaluate cell
     - `Space + r` (visual) - Evaluate selection
     - `Space + rd` - Delete cell
     - `Space + oh` - Hide output
     - `Space + os` - Show/enter output
     - `Space + ri` - Interrupt kernel
     - `Space + rs` - Restart kernel
     - `Space + mv` - Select virtual environment

4. **Custom notebook handler**
   - Replaced buggy `jupytext.nvim` plugin with custom CLI-based solution
   - Converts `.ipynb` ↔ `.py` (percent format with `# %%` cell markers)
   - Automatic virtual environment detection from parent directories
   - Searches for: `.venv`, `venv`, `env`, `.env`, `virtualenv`
   - Auto-installs ipykernel in selected venv if missing
   - Automatic kernel selection prompt on notebook open

5. **Added markdown rendering**
   - Plugin: `render-markdown.nvim`
   - Beautiful code block highlighting
   - Styled headings, bullets, checkboxes, quotes

6. **Fixed kernel issues**
   - Removed broken kernel specs (my_env, myvenv, spikes-venv, spiking-venv)
   - Created valid system Python 3 kernel
   - Auto-detects and registers venv kernels

### File Structure
```
~/.config/nvim/
├── init.lua (swap file disable for .ipynb)
├── lua/
│   ├── config/
│   │   ├── options.lua
│   │   └── lazy.lua
│   └── plugins/
│       ├── notebook.lua (molten + custom jupytext handler)
│       └── markdown.lua (render-markdown config)
└── CLAUDE.md (this file)
```

### How to Use
1. Open a `.ipynb` file in Neovim
2. Select virtual environment from prompt (or use system Python)
3. Notebook appears as clean Python code with `# %%` cell markers
4. Use `Space + r*` commands to execute code
5. Save with `:w` to convert back to `.ipynb` format

### Cell Detection Fix
Molten doesn't natively detect cells from `# %%` markers. Added custom functions:
- `get_cell_boundaries()` - Finds start/end of cell based on `# %%` markers
- `run_current_cell()` - Executes entire cell between markers, exits visual mode, restores cursor
- `Space + rr` now properly runs the current cell regardless of cursor position
- `]c` / `[c` - Navigate to next/previous cell

### Visual Indicators
Added beautiful visual markers with distinct backgrounds for cells:
- **Code cells**: Blue badge "  PYTHON CODE" with dark blue background
- **Markdown cells**: Green badge "󰷈 MARKDOWN CELL" with dark green background
- **Markdown content**: Green italic text with subtle green-tinted background
- Clear visual separation between cell types
- Updates automatically as you type

### All Keybindings
**Execution:**
- `Space + mi` - Initialize kernel (prompts for venv selection)
- `Space + rl` - Run current line
- `Space + rr` - Run current cell (stays in normal mode, restores cursor)
- `Space + r` (visual) - Run selection
- `Space + e` - Evaluate operator

**Cell Navigation:**
- `]c` - Go to next cell
- `[c` - Go to previous cell

**Output:**
- `Space + oh` - Hide output
- `Space + os` - Show/enter output
- `Space + rd` - Delete cell output

**Kernel:**
- `Space + ri` - Interrupt kernel
- `Space + rs` - Restart kernel
- `Space + mv` - Change virtual environment

### Known Limitations
- Markdown cells appear as Python comments (not rendered)
- Output rendering limited compared to Jupyter Lab
- Requires tmux with allow-passthrough for images
