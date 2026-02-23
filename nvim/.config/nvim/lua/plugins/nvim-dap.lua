-- Python DAP Debugging (adapted from NeuralNine's config)
-- Requires: pip install debugpy  (or :MasonInstall debugpy)
--
-- Keybindings:
--   <leader>db  - Toggle breakpoint
--   <leader>dc  - Continue / Start
--   <leader>do  - Step over
--   <leader>di  - Step into
--   <leader>dO  - Step out
--   <leader>dq  - Terminate session
--   <leader>du  - Toggle DAP UI

local dap_ok, dap = pcall(require, "dap")
if not dap_ok then return end

local dapui_ok, dapui = pcall(require, "dapui")
local dap_python_ok, dap_python = pcall(require, "dap-python")
local dap_vtext_ok = pcall(require, "nvim-dap-virtual-text")

-- DAP UI
if dapui_ok then
    dapui.setup({})

    -- Auto-open UI when debugging starts
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end
end

-- Virtual text: show variable values inline while debugging
if dap_vtext_ok then
    require("nvim-dap-virtual-text").setup({
        commented = true,  -- show virtual text alongside comment
    })
end

-- Python adapter: use Mason's debugpy if available, else system python
if dap_python_ok then
    local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    if vim.fn.executable(mason_debugpy) == 1 then
        dap_python.setup(mason_debugpy)
    else
        dap_python.setup("python3")
    end
end

-- Breakpoint signs
vim.fn.sign_define("DapBreakpoint", {
    text    = "",
    texthl  = "DiagnosticSignError",
    linehl  = "",
    numhl   = "",
})
vim.fn.sign_define("DapBreakpointRejected", {
    text    = "",
    texthl  = "DiagnosticSignError",
    linehl  = "",
    numhl   = "",
})
vim.fn.sign_define("DapStopped", {
    text    = "",
    texthl  = "DiagnosticSignWarn",
    linehl  = "Visual",
    numhl   = "DiagnosticSignWarn",
})

-- Keybindings
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, vim.tbl_extend("force", opts, { desc = "DAP: Toggle breakpoint" }))
vim.keymap.set("n", "<leader>dc", function() dap.continue() end,          vim.tbl_extend("force", opts, { desc = "DAP: Continue/Start" }))
vim.keymap.set("n", "<leader>do", function() dap.step_over() end,         vim.tbl_extend("force", opts, { desc = "DAP: Step over" }))
vim.keymap.set("n", "<leader>di", function() dap.step_into() end,         vim.tbl_extend("force", opts, { desc = "DAP: Step into" }))
vim.keymap.set("n", "<leader>dO", function() dap.step_out() end,          vim.tbl_extend("force", opts, { desc = "DAP: Step out" }))
vim.keymap.set("n", "<leader>dq", function() dap.terminate() end,         vim.tbl_extend("force", opts, { desc = "DAP: Terminate" }))

if dapui_ok then
    vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, vim.tbl_extend("force", opts, { desc = "DAP: Toggle UI" }))
end
