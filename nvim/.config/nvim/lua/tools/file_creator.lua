local M = {}

function M.create_file(initial_dir)
  local current_dir = initial_dir
  if not current_dir or current_dir == "" then
    local buf_name = vim.api.nvim_buf_get_name(0)
    current_dir = buf_name ~= "" and (vim.fn.fnamemodify(buf_name, ":p:h") .. "/") or (vim.fn.getcwd() .. "/")
  end

  vim.ui.input({
    prompt = "Create new file: ",
    default = current_dir,
    completion = "file",
  }, function(input)
    if not input or input:match("^%s*$") then return end

    local full_path = vim.fn.fnamemodify(vim.trim(input), ":p")
    local parent_dir = vim.fn.fnamemodify(full_path, ":h")
    if vim.fn.isdirectory(parent_dir) ~= 1 then
      vim.fn.mkdir(parent_dir, "p")
    end

    if vim.fn.filereadable(full_path) ~= 1 then
      local f = io.open(full_path, "w")
      if f then f:close() end
    end

    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.notify("Created: " .. vim.fn.fnamemodify(full_path, ":."), vim.log.levels.INFO)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("CreateFile", function(opts)
    M.create_file(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", complete = "dir", desc = "Create new file in specific directory" })

  vim.api.nvim_create_user_command("NewFile", function(opts)
    M.create_file(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", complete = "dir", desc = "Create new file in specific directory" })
end

return M
