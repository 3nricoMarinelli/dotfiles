local M = {}

local LICENSE_FILENAMES = {
  "LICENSE",
  "LICENSE.txt",
  "LICENSE.md",
  "LICENCE",
  "LICENCE.txt",
  "LICENCE.md",
  "COPYING",
  "COPYING.txt",
  "COPYRIGHT",
}

function M.get_git_root(bufnr)
  local path = bufnr and vim.api.nvim_buf_get_name(bufnr) or vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.getcwd()
  end
  return vim.fs.root(path, { ".git" }) or vim.fn.getcwd()
end

function M.get_repo_name(git_root)
  -- Try git remote origin url
  local handle = io.popen("git -C " .. vim.fn.shellescape(git_root) .. " config --get remote.origin.url 2>/dev/null")
  if handle then
    local url = handle:read("*a")
    handle:close()
    if url and url ~= "" then
      url = url:gsub("%s+$", "")
      local repo = url:match("/([^/]+)%.git$") or url:match("/([^/]+)$") or url:match(":([^/]+)%.git$")
      if repo and repo ~= "" then
        return repo
      end
    end
  end

  return vim.fs.basename(git_root) or "project"
end

function M.get_author(git_root)
  local handle = io.popen("git -C " .. vim.fn.shellescape(git_root) .. " config user.name 2>/dev/null")
  local name = handle and handle:read("*a")
  if handle then handle:close() end

  local email_handle = io.popen("git -C " .. vim.fn.shellescape(git_root) .. " config user.email 2>/dev/null")
  local email = email_handle and email_handle:read("*a")
  if email_handle then email_handle:close() end

  name = name and name:gsub("%s+$", "") or ""
  email = email and email:gsub("%s+$", "") or ""

  if name ~= "" and email ~= "" then
    return string.format("%s <%s>", name, email)
  elseif name ~= "" then
    return name
  end

  return os.getenv("USER") or "Author"
end

function M.get_date()
  return os.date("%Y-%m-%d")
end

function M.find_license_file(git_root)
  for _, filename in ipairs(LICENSE_FILENAMES) do
    local path = git_root .. "/" .. filename
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == "file" then
      return path
    end
  end

  -- Fallback: check subdirectories or case-insensitive search in root
  local found = vim.fs.find(function(name)
    local lower = name:lower()
    return lower == "license" or lower:match("^license%.") or lower == "copying"
  end, { path = git_root, type = "file", limit = 1 })

  if #found > 0 then
    return found[1]
  end

  return nil
end

function M.read_license_lines(license_path)
  if not license_path then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, license_path)
  if not ok or not lines or #lines == 0 then
    return nil
  end

  -- Trim leading and trailing blank lines
  while #lines > 0 and lines[1]:match("^%s*$") do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.remove(lines, #lines)
  end

  return lines
end

function M.get_comment_prefix(bufnr)
  local ft = bufnr and vim.bo[bufnr].filetype or vim.bo.filetype
  if ft == "python" or ft == "sh" or ft == "bash" or ft == "zsh" or ft == "yaml" then
    return "# "
  elseif ft == "lua" then
    return "-- "
  elseif ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ft == "rust" or ft == "javascript" or ft == "typescript" then
    return "// "
  end

  -- Derive from commentstring
  local cs = vim.bo[bufnr or 0].commentstring
  if cs and cs ~= "" then
    local p = cs:match("^(.-)%%s")
    if p and p ~= "" then
      if not p:match("%s$") then
        p = p .. " "
      end
      return p
    end
  end

  return "// "
end

function M.get_license_header_lines(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local git_root = M.get_git_root(bufnr)
  local repo_name = M.get_repo_name(git_root)
  local author = M.get_author(git_root)
  local date = M.get_date()
  local license_path = M.find_license_file(git_root)
  local license_lines = M.read_license_lines(license_path)

  local prefix = M.get_comment_prefix(bufnr)
  local divider = prefix .. string.rep("=", 76)

  local result = {}
  table.insert(result, divider)
  table.insert(result, prefix .. "Repository:   " .. repo_name)
  table.insert(result, prefix .. "Author:       " .. author)
  table.insert(result, prefix .. "Created:      " .. date)

  if license_lines and #license_lines > 0 then
    table.insert(result, prefix)
    table.insert(result, prefix .. "License (" .. vim.fs.basename(license_path) .. "):")
    for _, line in ipairs(license_lines) do
      if line:match("^%s*$") then
        local empty_prefix = (prefix:gsub("%s+$", ""))
        table.insert(result, empty_prefix)
      else
        table.insert(result, prefix .. "  " .. line)
      end
    end
  else
    table.insert(result, prefix)
    table.insert(result, prefix .. "License:")
    table.insert(result, prefix .. "  SPDX-License-Identifier: MIT")
  end

  table.insert(result, divider)
  return result
end

function M.insert_header(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local header = M.get_license_header_lines(bufnr)
  table.insert(header, "") -- trailing blank line

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, header)
  vim.notify("License header generated", vim.log.levels.INFO)
end

function M.setup()
  -- Register user command
  vim.api.nvim_create_user_command("LicenseHeader", function()
    M.insert_header()
  end, { desc = "Generate license header with author, repo, and date" })

  -- Register LuaSnip snippet for all languages
  local ok, ls = pcall(require, "luasnip")
  if ok then
    local s = ls.snippet
    local f = ls.function_node

    ls.add_snippets("all", {
      s("license", {
        f(function()
          return M.get_license_header_lines()
        end, {}),
      }),
      s("header", {
        f(function()
          return M.get_license_header_lines()
        end, {}),
      }),
    })
  end
end

return M
