return {
  -- Molten for running code
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true

      -- Enable cell detection for Python files
      vim.g.molten_use_border_highlights = true
      vim.g.molten_enter_output_behavior = "open_then_enter"
    end,
    config = function()
      local keymap = vim.keymap.set

      -- Function to find cell boundaries based on # %% markers
      local function get_cell_boundaries()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)
        local start_line = 1
        local end_line = total_lines

        -- Find the start of the current cell (search backwards for # %%)
        for line_num = current_line, 1, -1 do
          local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
          if line and line:match("^# %%") then
            start_line = line_num
            break
          end
        end

        -- Find the end of the current cell (search forwards for next # %%)
        for line_num = current_line + 1, total_lines do
          local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
          if line and line:match("^# %%") then
            end_line = line_num - 1
            break
          end
        end

        return start_line, end_line
      end

      -- Function to run the current cell
      local function run_current_cell()
        local start_line, end_line = get_cell_boundaries()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        -- Skip the # %% marker line itself if we're starting on it
        local first_line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
        if first_line and first_line:match("^# %%") then
          start_line = start_line + 1
        end

        -- Skip trailing empty lines and comments
        while end_line > start_line do
          local line = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1]
          if line and line:match("%S") and not line:match("^%s*#") then
            break
          end
          end_line = end_line - 1
        end

        if start_line <= end_line then
          -- Select and evaluate the cell range
          vim.api.nvim_win_set_cursor(0, { start_line, 0 })
          vim.cmd("normal! V")
          vim.api.nvim_win_set_cursor(0, { end_line, 0 })
          vim.cmd("MoltenEvaluateVisual")

          -- Exit visual mode and restore cursor
          vim.schedule(function()
            -- Force exit visual mode
            local mode = vim.api.nvim_get_mode().mode
            if mode:match("[vV]") then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
            end
            -- Restore cursor position
            vim.api.nvim_win_set_cursor(0, cursor_pos)
          end)
        end
      end

      -- Initialize
      keymap("n", "<leader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize Molten" })

      -- Evaluate
      keymap("n", "<leader>e", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "Evaluate operator selection" })
      keymap("n", "<leader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
      keymap("n", "<leader>rr", run_current_cell, { silent = true, desc = "Run current cell" })
      keymap("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "Evaluate visual selection" })

      -- Output management
      keymap("n", "<leader>rd", ":MoltenDelete<CR>", { silent = true, desc = "Delete cell" })
      keymap("n", "<leader>oh", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })
      keymap("n", "<leader>os", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Show/enter output" })

      -- Interrupt and restart
      keymap("n", "<leader>ri", ":MoltenInterrupt<CR>", { silent = true, desc = "Interrupt kernel" })
      keymap("n", "<leader>rs", ":MoltenRestart<CR>", { silent = true, desc = "Restart kernel" })

      -- Navigate between cells
      keymap("n", "]c", function()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)
        for line_num = current_line + 1, total_lines do
          local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
          if line and line:match("^# %%") then
            vim.api.nvim_win_set_cursor(0, { line_num, 0 })
            return
          end
        end
      end, { silent = true, desc = "Go to next cell" })

      keymap("n", "[c", function()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        for line_num = current_line - 1, 1, -1 do
          local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
          if line and line:match("^# %%") then
            vim.api.nvim_win_set_cursor(0, { line_num, 0 })
            return
          end
        end
      end, { silent = true, desc = "Go to previous cell" })

      -- Select venv (for notebooks)
      keymap("n", "<leader>mv", function()
        if vim.b.found_venvs and #vim.b.found_venvs > 0 then
          local choices = {}
          for i, venv in ipairs(vim.b.found_venvs) do
            table.insert(choices, string.format("%d. %s (%s)", i, venv.name, venv.path))
          end
          table.insert(choices, (#vim.b.found_venvs + 1) .. ". Use system Python")

          vim.ui.select(choices, {
            prompt = "Select Python environment:",
          }, function(choice, idx)
            if idx and idx <= #vim.b.found_venvs then
              -- Re-initialize with selected venv
              local venv = vim.b.found_venvs[idx]
              local kernel_name = "venv_" .. vim.fn.fnamemodify(venv.path, ":t")
              vim.cmd("MoltenInit " .. kernel_name)
            elseif idx == #vim.b.found_venvs + 1 then
              vim.cmd("MoltenInit python3")
            end
          end)
        else
          print("No virtual environments found in parent directories")
        end
      end, { silent = true, desc = "Select virtual environment" })
    end,
  },

  -- Image rendering
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  -- Custom notebook handling using jupytext CLI
  {
    dir = vim.fn.stdpath("config") .. "/lua/custom/notebook",
    name = "custom-notebook",
    config = function()
      -- Function to find virtual environments in parent directories
      local function find_venvs(start_path)
        local venvs = {}
        local venv_names = { ".venv", "venv", "env", ".env", "virtualenv" }
        local path = start_path

        -- Search up to 5 parent directories
        for _ = 1, 5 do
          for _, venv_name in ipairs(venv_names) do
            local venv_path = path .. "/" .. venv_name
            local python_path = venv_path .. "/bin/python"

            if vim.fn.isdirectory(venv_path) == 1 and vim.fn.executable(python_path) == 1 then
              table.insert(venvs, {
                name = venv_name,
                path = venv_path,
                python = python_path,
              })
            end
          end

          -- Move to parent directory
          local parent = vim.fn.fnamemodify(path, ":h")
          if parent == path then
            break
          end
          path = parent
        end

        return venvs
      end

      -- Function to initialize molten with selected venv
      local function init_molten_with_venv(venv)
        -- Check if ipykernel is installed in the venv
        local check_cmd = venv.python .. " -c 'import ipykernel' 2>/dev/null"
        local has_ipykernel = vim.fn.system(check_cmd)

        if vim.v.shell_error ~= 0 then
          print("Installing ipykernel in " .. venv.name .. "...")
          vim.fn.system(venv.python .. " -m pip install ipykernel")
        end

        -- Install kernel spec
        local kernel_name = "venv_" .. vim.fn.fnamemodify(venv.path, ":t")
        local install_cmd = string.format(
          "%s -m ipykernel install --user --name %s --display-name 'Python (%s)'",
          venv.python,
          kernel_name,
          venv.name
        )
        vim.fn.system(install_cmd)

        -- Initialize molten with this kernel
        vim.schedule(function()
          vim.cmd("MoltenInit " .. kernel_name)
        end)
      end

      -- Function to add visual indicators for cell markers
      local function setup_cell_highlights(bufnr)
        -- Define highlight groups with distinct colors
        vim.api.nvim_set_hl(0, "NotebookCodeCell", { fg = "#61AFEF", bg = "#2C3E50", bold = true })
        vim.api.nvim_set_hl(0, "NotebookMarkdownCell", { fg = "#98C379", bg = "#27472C", bold = true })
        vim.api.nvim_set_hl(0, "NotebookMarkdownContent", { fg = "#98C379", italic = true })
        vim.api.nvim_set_hl(0, "NotebookMarkdownBg", { bg = "#1E2D1E" })

        -- Create namespaces
        local ns_id = vim.api.nvim_create_namespace("notebook_cells")
        local ns_md = vim.api.nvim_create_namespace("notebook_markdown")

        -- Clear existing virtual text and highlights
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
        vim.api.nvim_buf_clear_namespace(bufnr, ns_md, 0, -1)

        -- Add virtual text to cell markers and highlight markdown content
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local in_markdown = false
        for i, line in ipairs(lines) do
          -- Check for markdown cell first (more specific pattern)
          if line:match("^# %%.*%[markdown%]") or line:match("^# %% %[markdown%]") then
            -- Markdown cell marker - green with document icon and background
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
              virt_text = { { "  󰷈  MARKDOWN CELL ", "NotebookMarkdownCell" } },
              virt_text_pos = "eol",
              line_hl_group = "NotebookMarkdownBg",
            })
            in_markdown = true
          elseif line:match("^# %%") then
            -- Code cell marker - blue with Python icon and background
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
              virt_text = { { "    PYTHON CODE ", "NotebookCodeCell" } },
              virt_text_pos = "eol",
            })
            in_markdown = false
          elseif in_markdown and line:match("^#") then
            -- Highlight markdown content lines with green tint and background
            vim.api.nvim_buf_set_extmark(bufnr, ns_md, i - 1, 0, {
              end_col = #line,
              hl_group = "NotebookMarkdownContent",
              line_hl_group = "NotebookMarkdownBg",
            })
          end
        end
      end

      -- Convert .ipynb to .py (percent format) on open using jupytext CLI
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "*.ipynb",
        callback = function(args)
          local ipynb_file = args.file
          local temp_py = vim.fn.tempname() .. ".py"

          -- Convert using jupytext CLI to percent format (uses # %% cell markers)
          local result = vim.fn.system({
            "python3",
            "-m",
            "jupytext",
            "--to",
            "py:percent",
            "--output",
            temp_py,
            ipynb_file,
          })

          if vim.v.shell_error == 0 then
            -- Read the python file into the buffer
            vim.cmd("edit " .. temp_py)
            vim.bo.filetype = "python"
            vim.bo.buftype = "acwrite"

            -- Store the original ipynb path
            vim.b.ipynb_file = ipynb_file
            vim.b.temp_py = temp_py

            -- Add visual indicators for cells
            vim.schedule(function()
              setup_cell_highlights(vim.api.nvim_get_current_buf())
            end)

            -- Update highlights when text changes
            vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
              buffer = vim.api.nvim_get_current_buf(),
              callback = function()
                setup_cell_highlights(vim.api.nvim_get_current_buf())
              end,
            })

            -- Find venvs in parent directories
            local notebook_dir = vim.fn.fnamemodify(ipynb_file, ":h")
            local venvs = find_venvs(notebook_dir)

            -- Store venvs for later use
            vim.b.found_venvs = venvs

            -- Auto-prompt to select venv after buffer is loaded
            if #venvs > 0 then
              vim.schedule(function()
                local choices = {}
                for i, venv in ipairs(venvs) do
                  table.insert(choices, string.format("%d. %s (%s)", i, venv.name, venv.path))
                end
                table.insert(choices, (#venvs + 1) .. ". Use system Python")

                vim.ui.select(choices, {
                  prompt = "Select Python environment for notebook:",
                }, function(choice, idx)
                  if idx and idx <= #venvs then
                    init_molten_with_venv(venvs[idx])
                  elseif idx == #venvs + 1 then
                    vim.schedule(function()
                      vim.cmd("MoltenInit python3")
                    end)
                  end
                end)
              end)
            else
              -- No venv found, prompt for system python
              vim.schedule(function()
                vim.cmd("MoltenInit python3")
              end)
            end

            -- Save back to ipynb on write
            vim.api.nvim_create_autocmd("BufWriteCmd", {
              buffer = args.buf,
              callback = function()
                vim.fn.system({
                  "python3",
                  "-m",
                  "jupytext",
                  "--to",
                  "ipynb",
                  "--output",
                  vim.b.ipynb_file,
                  vim.b.temp_py,
                })
                if vim.v.shell_error == 0 then
                  vim.bo.modified = false
                  print("Saved to " .. vim.b.ipynb_file)
                else
                  vim.api.nvim_err_writeln("Failed to save notebook")
                end
              end,
            })
          else
            vim.api.nvim_err_writeln("Failed to convert notebook: " .. result)
          end
        end,
      })
    end,
  },
}
