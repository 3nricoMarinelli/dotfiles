#!/usr/bin/env nvim -u NONE -N --noplugin -i NONE -S
-- Recursive formatter using Neovim + Conform
-- Traverses entire filesystem tree, including hidden files/dirs
-- Skips symlinks and dangerous directories (.git, node_modules, etc.)
-- Usage: nvim --headless -u ~/.config/nvim/init.lua -S format-recursive.lua -- /path/to/dir

local dir = vim.fn.argv()[1] or "."

-- Add Mason bin to PATH (same as in plugins/mason.lua)
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

-- Ensure Conform is loaded
local conform_ok, conform = pcall(require, "conform")
if not conform_ok then
  print("✗ Error: Conform not loaded!")
  vim.cmd("qa!")
  return
end

-- Directories to skip (don't traverse into them)
local SKIP_DIRS = {
  ".git",
  ".hg",
  ".svn",
  ".cache",
  ".venv",
  "venv",
  "node_modules",
  "__pycache__",
  ".pytest_cache",
  "dist",
  "build",
  "target", -- Rust
  ".o", -- Compiled objects
  ".a", -- Static libraries
}

-- Build extension-to-filetype map from conform config
local ext_to_ft = {}
for ft, _ in pairs(conform.formatters_by_ft) do
  -- Map filetype to itself (we'll check against formatters_by_ft later)
  ext_to_ft[ft] = ft
end

if vim.tbl_isempty(ext_to_ft) then
  print("✗ Error: No formatters configured!")
  vim.cmd("qa!")
  return
end

-- Check if directory should be skipped
local function should_skip_dir(dirname)
  for _, skip in ipairs(SKIP_DIRS) do
    if dirname == skip then
      return true
    end
  end
  return false
end

-- Get file extension from path
local function get_extension(filename)
  local ext = filename:match("%.([^%.]+)$")
  return ext or ""
end

-- Check if file extension has a formatter
local function has_formatter(filename)
  local ext = get_extension(filename)
  if ext == "" then
    return false
  end
  -- Check if this extension's filetype has formatters configured
  return ext_to_ft[ext] ~= nil
end

-- Recursively walk filesystem tree
local function walk_tree(path, callback)
  local handle = vim.loop.fs_scandir(path)
  if not handle then
    return
  end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    local fullpath = path .. "/" .. name
    local stat = vim.loop.fs_stat(fullpath)

    -- Skip symlinks
    if stat and stat.type == "link" then
      goto skip
    end

    if type == "directory" then
      -- Check if directory should be skipped
      if not should_skip_dir(name) then
        walk_tree(fullpath, callback)
      end
    elseif type == "file" then
      callback(fullpath, name)
    end

    ::skip::
  end
end

-- Format all files
local function format_all(root_path)
  local formatted_count = 0
  local error_count = 0
  local skipped_count = 0

  -- Normalize path (remove trailing slash)
  root_path = root_path:gsub("/$", "")

  -- Verify root path exists
  local root_stat = vim.loop.fs_stat(root_path)
  if not root_stat or root_stat.type ~= "directory" then
    print(string.format("✗ Error: '%s' is not a valid directory", root_path))
    vim.cmd("qa!")
    return
  end

  print(string.format("Scanning: %s", root_path))
  print(string.format("Formatters available in conform: %s", vim.inspect(vim.tbl_keys(ext_to_ft))))
  print("")

  -- Walk tree and format files
  walk_tree(root_path, function(fullpath, filename)
    if not has_formatter(fullpath) then
      skipped_count = skipped_count + 1
      return
    end

    -- Open file
    local buf = vim.fn.bufadd(fullpath)
    vim.fn.bufload(buf)

    -- Format
    local ok, err = pcall(function()
      conform.format({ bufnr = buf, async = false })
    end)

    if ok then
      -- Write file
      vim.fn.writefile(vim.fn.getbufline(buf, 1, "$"), fullpath)
      print(string.format("✓ %s", fullpath))
      formatted_count = formatted_count + 1
    else
      print(string.format("✗ %s: %s", fullpath, err))
      error_count = error_count + 1
    end

    -- Unload buffer (force with ! to discard unsaved changes)
    vim.cmd("bwipeout! " .. buf)
  end)

  print(string.format("\n=== Summary ==="))
  print(string.format("Root: %s", root_path))
  print(string.format("Formatted: %d", formatted_count))
  print(string.format("Errors: %d", error_count))
  print(string.format("Skipped (no formatter): %d", skipped_count))
  print(string.format("Total files scanned: %d", formatted_count + error_count + skipped_count))
end

-- Run
format_all(dir)
vim.cmd("qa!")
