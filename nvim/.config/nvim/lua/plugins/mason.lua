-- Mason: package manager for LSP servers, linters, and formatters
-- :Mason to open the interactive UI
--
-- Manages Python tools automatically:
--   pylsp    - Python Language Server
--   ruff     - Python linter/formatter (also used by nvim-lint)
--   isort    - Python import sorter
--   debugpy  - Python debug adapter (for nvim-dap)
--
-- Mason installs tools to: ~/.local/share/nvim/mason/bin/
-- We add this to PATH so vim.lsp.start and external tools find them.

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then return end

-- Add Mason's bin dir to PATH so managed binaries are discoverable
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

mason.setup({
    ui = {
        icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
        },
    },
    pip = {
        upgrade_pip = true,  -- keep pip up-to-date when managing Python packages
    },
})

-- mason-lspconfig: bridges Mason and nvim-lspconfig
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if mason_lspconfig_ok then
    mason_lspconfig.setup({
        ensure_installed      = { "pylsp" },
        automatic_installation = true,
    })
end

-- mason-tool-installer: auto-installs non-LSP tools (linters, formatters, DAP)
local mason_tool_installer_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if mason_tool_installer_ok then
    mason_tool_installer.setup({
        ensure_installed = {
            "ruff",     -- Python linter & formatter
            "isort",    -- Python import sorter
            "debugpy",  -- Python debug adapter (nvim-dap-python)
        },
        auto_update = false,
        run_on_start = true,
    })
end
