-- telescope-launcher: Wrapper around telescope for startup picker with Tab toggle
-- DEPRECATED: Use git-root-search.lua instead for consistent git-root behavior
-- Kept for backward compatibility, but new code should use git-root-search.lua
--
-- This file is maintained for reference and can be removed after full migration
-- to git-root-search.lua across all entry points (mappings, dashboard, commands)

local git_root_search = require("utils.git-root-search")

local M = {}

-- Main launcher: Start with Files picker
function M.startup()
  git_root_search.startup()
end

-- Open Files picker with Tab toggle to Grep
function M.open_files()
  git_root_search.open_files()
end

-- Open Live Grep picker with Tab toggle back to Files
function M.open_grep()
  git_root_search.open_grep()
end

return M

