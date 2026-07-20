-- Shared utility for Telescope file/grep search with git-root detection
-- Behavior: Find files in first directory containing .git (navigating up parents)
-- Falls back to current working directory if no .git found
-- Includes Tab toggle between files ↔ grep

local M = {}

-- Find git root by navigating up parent directories
-- Returns git root path or current working directory as fallback
local function find_git_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  local git_root = handle:read("*a"):gsub("\n", "")
  handle:close()

  if git_root ~= "" then
    return git_root
  else
    return vim.fn.getcwd()
  end
end

-- Open Files picker with Tab toggle to Grep
-- Searches in git root or current directory
function M.open_files()
    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
        vim.notify("telescope not yet loaded", vim.log.levels.WARN)
        return
    end

    local ok_strat, layout_strategies = pcall(require, "telescope.pickers.layout_strategies")
    if not ok_strat then
        vim.notify("telescope layout strategies not available", vim.log.levels.WARN)
        return
    end

    local ok_actions, actions = pcall(require, "telescope.actions")
    if not ok_actions then
        vim.notify("telescope.actions not available", vim.log.levels.WARN)
        return
    end

    local cwd = find_git_root()

    layout_strategies.dynamic_orientation = function(self, max_columns, max_lines, _)
        local strategy = (max_lines >= max_columns or max_columns < 120) and 'vertical' or 'horizontal'

        local horizontal_config = {
            width = 0.99,
            height = 0.99,
            preview_width = 0.5,
        }
        local vertical_config = {
            width = 0.99,
            height = 0.99,
            preview_height = 0.5,
        }

        local active_config = (strategy == 'vertical') and vertical_config or horizontal_config

        return layout_strategies[strategy](self, max_columns, max_lines, active_config)
    end

    builtin.find_files({
        cwd = cwd,
        layout_strategy = "dynamic_orientation",
        layout_config = {},
        attach_mappings = function(prompt_bufnr, map)
            map("i", "<Tab>", function()
                actions.close(prompt_bufnr)
                vim.schedule(function()
                    M.open_grep()
                end)
            end)

            map("i", "<S-Up>", actions.preview_scrolling_up)
            map("i", "<S-Down>", actions.preview_scrolling_down)
            map("i", "<S-Left>", actions.preview_scrolling_left)
            map("i", "<S-Right>", actions.preview_scrolling_right)
            return true
        end,
    })
end

-- Open Live Grep picker with Tab toggle back to Files
-- Searches in git root or current directory
function M.open_grep()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope not yet loaded", vim.log.levels.WARN)
    return
  end

  local ok_strat, layout_strategies = pcall(require, "telescope.pickers.layout_strategies")
  if not ok_strat then
      vim.notify("telescope layout strategies not available", vim.log.levels.WARN)
      return
  end

  local ok_actions, actions = pcall(require, "telescope.actions")
  if not ok_actions then
    vim.notify("telescope.actions not available", vim.log.levels.WARN)
    return
  end

  local cwd = find_git_root()

    layout_strategies.dynamic_orientation = function(self, max_columns, max_lines, _)
        local strategy = (max_lines >= max_columns or max_columns < 120) and 'vertical' or 'horizontal'

        local horizontal_config = {
            width = 0.99,
            height = 0.99,
            preview_width = 0.5,
        }
        local vertical_config = {
            width = 0.99,
            height = 0.99,
            preview_height = 0.5,
        }

        local active_config = (strategy == 'vertical') and vertical_config or horizontal_config

        -- Use the correct variable name we imported above
        return layout_strategies[strategy](self, max_columns, max_lines, active_config)
    end

  builtin.live_grep({
      cwd = cwd,
      layout_strategy = "dynamic_orientation",
      layout_config = {},
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<Tab>", function()
        -- Use schedule to ensure picker closes completely before opening next
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_files()
        end)
      end)
      -- Preview navigation with Shift+arrow keys
      map("i", "<S-Up>", actions.preview_scrolling_up)
      map("i", "<S-Down>", actions.preview_scrolling_down)
      map("i", "<S-Left>", actions.preview_scrolling_left)
      map("i", "<S-Right>", actions.preview_scrolling_right)
      return true
    end,
  })
end

-- Startup function: start with files
function M.startup()
  M.open_files()
end

return M
