local M = {}

local function find_git_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  local git_root = handle and handle:read("*a"):gsub("\n", "") or ""
  if handle then
    handle:close()
  end
  return git_root ~= "" and git_root or vim.fn.getcwd()
end

local function get_ignore_files(cwd)
  local ignore_files = {}
  local global_ignore = vim.fn.stdpath("config") .. "/.telescopeignore"
  local local_ignore = cwd .. "/.telescopeignore"

  if vim.fn.filereadable(global_ignore) == 1 then
    table.insert(ignore_files, global_ignore)
  end
  if vim.fn.filereadable(local_ignore) == 1 then
    table.insert(ignore_files, local_ignore)
  end
  return ignore_files
end

local function get_fd_command(cwd)
  local cmd = { "fd", "--type", "f", "--follow", "--hidden" }
  for _, file in ipairs(get_ignore_files(cwd)) do
    table.insert(cmd, "--ignore-file")
    table.insert(cmd, file)
  end
  return cmd
end

local function get_rg_args(cwd)
  local args = { "--hidden", "--follow" }
  for _, file in ipairs(get_ignore_files(cwd)) do
    table.insert(args, "--ignore-file")
    table.insert(args, file)
  end
  return args
end

-- Open single, multi-selection, or all '*' matches
local function smart_open(prompt_bufnr)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt = action_state.get_current_line()
  local multi_selections = picker:get_multi_selection()

  if multi_selections and #multi_selections > 1 then
    actions.close(prompt_bufnr)
    for _, entry in ipairs(multi_selections) do
      local path = entry.path or entry.filename or entry.value or entry[1]
      if path then
        vim.cmd("badd " .. vim.fn.fnameescape(path))
      end
    end
    local first = multi_selections[1].path or multi_selections[1].filename or multi_selections[1].value or multi_selections[1][1]
    if first then
      vim.cmd("edit " .. vim.fn.fnameescape(first))
    end
    return
  end

  if prompt:match("%*") then
    local matched_entries = {}
    for entry in picker.manager:iter() do
      table.insert(matched_entries, entry)
    end

    if #matched_entries > 1 then
      actions.close(prompt_bufnr)
      for _, entry in ipairs(matched_entries) do
        local path = entry.path or entry.filename or entry.value or entry[1]
        if path then
          vim.cmd("badd " .. vim.fn.fnameescape(path))
        end
      end
      local first = matched_entries[1].path or matched_entries[1].filename or matched_entries[1].value or matched_entries[1][1]
      if first then
        vim.cmd("edit " .. vim.fn.fnameescape(first))
      end
      return
    end
  end

  actions.select_default(prompt_bufnr)
end

function M.open_files(opts)
  opts = opts or {}
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then return end

  local ok_strat, layout_strategies = pcall(require, "telescope.pickers.layout_strategies")
  if not ok_strat then return end

  local ok_actions, actions = pcall(require, "telescope.actions")
  local action_state = require("telescope.actions.state")
  if not ok_actions then return end

  local cwd = opts.cwd or find_git_root()

  layout_strategies.dynamic_orientation = function(self, max_columns, max_lines, _)
    local strategy = (max_lines >= max_columns or max_columns < 120) and "vertical" or "horizontal"
    local horizontal_config = { width = 0.99, height = 0.99, preview_width = 0.5 }
    local vertical_config = { width = 0.99, height = 0.99, preview_height = 0.5 }
    local active_config = (strategy == "vertical") and vertical_config or horizontal_config
    return layout_strategies[strategy](self, max_columns, max_lines, active_config)
  end

  builtin.find_files({
    prompt_title = "Find Files (" .. vim.fn.fnamemodify(cwd, ":~") .. ")",
    cwd = cwd,
    default_text = opts.default_text or "",
    find_command = get_fd_command(cwd),
    layout_strategy = "dynamic_orientation",
    layout_config = {},
    attach_mappings = function(prompt_bufnr, map)
      -- Tab toggles to grep preserving query
      map("i", "<Tab>", function()
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_grep({ default_text = current_text, cwd = cwd })
        end)
      end)

      map("i", "<CR>", smart_open)
      map("n", "<CR>", smart_open)
      map("i", "<C-Space>", actions.toggle_selection + actions.move_selection_worse)
      map("i", "<M-a>", actions.select_all)

      -- Navigate up or jump search directory
      map("i", "<M-u>", function()
        local parent = vim.fn.fnamemodify(cwd, ":h")
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_files({ cwd = parent, default_text = current_text })
        end)
      end)

      map("i", "<M-h>", function()
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_files({ cwd = vim.fn.expand("~"), default_text = current_text })
        end)
      end)

      map("i", "<M-r>", function()
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_files({ cwd = find_git_root(), default_text = current_text })
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

function M.open_grep(opts)
  opts = opts or {}
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then return end

  local ok_strat, layout_strategies = pcall(require, "telescope.pickers.layout_strategies")
  if not ok_strat then return end

  local ok_actions, actions = pcall(require, "telescope.actions")
  local action_state = require("telescope.actions.state")
  if not ok_actions then return end

  local cwd = opts.cwd or find_git_root()

  layout_strategies.dynamic_orientation = function(self, max_columns, max_lines, _)
    local strategy = (max_lines >= max_columns or max_columns < 120) and "vertical" or "horizontal"
    local horizontal_config = { width = 0.99, height = 0.99, preview_width = 0.5 }
    local vertical_config = { width = 0.99, height = 0.99, preview_height = 0.5 }
    local active_config = (strategy == "vertical") and vertical_config or horizontal_config
    return layout_strategies[strategy](self, max_columns, max_lines, active_config)
  end

  builtin.live_grep({
    prompt_title = "Live Grep (" .. vim.fn.fnamemodify(cwd, ":~") .. ")",
    cwd = cwd,
    default_text = opts.default_text or "",
    additional_args = get_rg_args(cwd),
    layout_strategy = "dynamic_orientation",
    layout_config = {},
    attach_mappings = function(prompt_bufnr, map)
      -- Tab toggles to files preserving query
      map("i", "<Tab>", function()
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_files({ default_text = current_text, cwd = cwd })
        end)
      end)

      map("i", "<CR>", smart_open)
      map("n", "<CR>", smart_open)
      map("i", "<C-Space>", actions.toggle_selection + actions.move_selection_worse)
      map("i", "<M-a>", actions.select_all)

      map("i", "<M-u>", function()
        local parent = vim.fn.fnamemodify(cwd, ":h")
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_grep({ cwd = parent, default_text = current_text })
        end)
      end)

      map("i", "<M-h>", function()
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_grep({ cwd = vim.fn.expand("~"), default_text = current_text })
        end)
      end)

      map("i", "<M-r>", function()
        local current_text = action_state.get_current_line()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          M.open_grep({ cwd = find_git_root(), default_text = current_text })
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

function M.open_grep_string(opts)
  opts = opts or {}
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then return end

  local cwd = opts.cwd or find_git_root()
  builtin.grep_string({
    prompt_title = "Grep String (" .. vim.fn.fnamemodify(cwd, ":~") .. ")",
    cwd = cwd,
    additional_args = get_rg_args(cwd),
  })
end

function M.startup()
  M.open_files()
end

return M
