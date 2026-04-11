-- persistence.nvim integration (session management)

local M = {}

local function ensure_setup()
  if _G.persistence_setup_done then
    return true
  end

  local ok, persistence = pcall(require, "persistence")
  if not ok then
    vim.notify("persistence.nvim is not available", vim.log.levels.ERROR)
    return false
  end

  persistence.setup({
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 1,
    branch = true,
  })

  _G.persistence_setup_done = true
  return true
end

function M.setup()
  if not ensure_setup() then
    return
  end

  if not _G.persistence_user_cmds_setup_done then
    vim.api.nvim_create_user_command("SessionLoad", function()
      require("persistence").load()
    end, {})

    vim.api.nvim_create_user_command("SessionLoadLast", function()
      M.load_last()
    end, {})

    vim.api.nvim_create_user_command("SessionSelect", function()
      require("persistence").select()
    end, {})

    vim.api.nvim_create_user_command("SessionStop", function()
      require("persistence").stop()
    end, {})

    -- Compatibility aliases for dashboard/usage clarity
    vim.api.nvim_create_user_command("PersistenceLoad", function()
      require("persistence").load()
    end, {})

    vim.api.nvim_create_user_command("PersistenceSelect", function()
      require("persistence").select()
    end, {})

    vim.api.nvim_create_user_command("PersistenceStop", function()
      require("persistence").stop()
    end, {})

    _G.persistence_user_cmds_setup_done = true
  end
end

function M.load_last()
  if not ensure_setup() then
    return
  end

  local persistence = require("persistence")
  local last = persistence.last()
  if last and vim.fn.filereadable(last) == 1 then
    persistence.load({ last = true })
  else
    vim.notify("No old session found", vim.log.levels.INFO)
  end
end

return M
