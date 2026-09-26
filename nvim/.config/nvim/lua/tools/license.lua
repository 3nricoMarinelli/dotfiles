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

  local found = vim.fs.find(function(name)
    local lower = name:lower()
    return lower == "license" or lower:match("^license%.") or lower == "copying"
  end, { path = git_root, type = "file", limit = 1 })

  return #found > 0 and found[1] or nil
end

function M.detect_license_name(git_root)
  local license_path = M.find_license_file(git_root)
  if not license_path then
    return "SPDX-License-Identifier: MIT"
  end

  local ok, lines = pcall(vim.fn.readfile, license_path)
  if ok and lines and #lines > 0 then
    for i = 1, math.min(15, #lines) do
      local line = lines[i]
      if line:match("MIT License") or line:match("The MIT License") then
        return "MIT License (SPDX-License-Identifier: MIT)"
      elseif line:match("Apache License") or line:match("Version 2%.0") then
        return "Apache 2.0 (SPDX-License-Identifier: Apache-2.0)"
      elseif line:match("GNU GENERAL PUBLIC LICENSE") or line:match("GPL") then
        return "GPL License"
      elseif line:match("BSD %d%-Clause") then
        return line:match("BSD %d%-Clause")
      elseif line:match("Mozilla Public License") then
        return "MPL 2.0"
      end
    end
    return vim.fs.basename(license_path)
  end
  return "SPDX-License-Identifier: MIT"
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

  local cs = vim.bo[bufnr or 0].commentstring
  if cs and cs ~= "" then
    local p = cs:match("^(.-)%%s")
    if p and p ~= "" then
      return p:match("%s$") and p or (p .. " ")
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
  local license = M.detect_license_name(git_root)
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  local filename = buf_name ~= "" and vim.fs.basename(buf_name) or nil

  local prefix = M.get_comment_prefix(bufnr)
  local divider = prefix .. string.rep("=", 76)

  local result = { divider }
  if filename and filename ~= "" then
    table.insert(result, prefix .. "File:         " .. filename)
  end
  table.insert(result, prefix .. "Project:      " .. repo_name)
  table.insert(result, prefix .. "Author:       " .. author)
  table.insert(result, prefix .. "Created:      " .. date)
  table.insert(result, prefix .. "Notice:       Handcrafted by a human")
  if license and license ~= "" then
    table.insert(result, prefix .. "License:      " .. license)
  end
  table.insert(result, divider)
  return result
end

function M.insert_header(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local header = M.get_license_header_lines(bufnr)
  table.insert(header, "")

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, header)
  vim.notify("Human author & project header inserted", vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command("LicenseHeader", function()
    M.insert_header()
  end, { desc = "Generate author, project, and human creation header" })

  local ok, ls = pcall(require, "luasnip")
  if ok then
    local s = ls.snippet
    local f = ls.function_node
    ls.add_snippets("all", {
      s("license", { f(function() return M.get_license_header_lines() end, {}) }),
      s("header", { f(function() return M.get_license_header_lines() end, {}) }),
    })
  end
end

return M
