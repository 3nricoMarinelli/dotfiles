-- Autocompletion configuration (adapted from cacharle/dotfiles)
-- Lightweight, LSP-powered completion without snippets bloat
--
-- Keybindings:
--   <Tab> - Confirm selection
--   <C-n> - Next item / trigger completion
--   <C-p> - Previous item
--   <C-b/f> - Scroll docs

local M = {}

function M.setup()
    local cmp_ok, cmp = pcall(require, "cmp")
    if not cmp_ok then return end

    local lspkind_ok, lspkind = pcall(require, "lspkind")

    cmp.setup({
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<Tab>"] = cmp.mapping.confirm({ select = true }),
            ["<C-n>"] = cmp.mapping(function(fallback)
                local has_words_before = function()
                    local unpack_fn = unpack or table.unpack
                    local line, col = unpack_fn(vim.api.nvim_win_get_cursor(0))
                    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end
                if cmp.visible() then
                    cmp.select_next_item()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<C-p>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        
        -- Sources priority (LSP first, then buffer)
        sources = {
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "path" },
            { name = "buffer", keyword_length = 3 },
        },
        
        -- UI formatting
        formatting = lspkind_ok and {
            format = lspkind.cmp_format({
                with_text = true,
                menu = {
                    nvim_lsp = "[LSP]",
                    path = "[path]",
                    buffer = "[buf]",
                }
            })
        } or nil,
        
        window = {
            documentation = cmp.config.window.bordered(),
        },
        
        experimental = {
            ghost_text = true,
        },
        
        performance = {
            debounce = 100,
            throttle = 100,
            fetching_timeout = 250,
        },
    })
end

-- Auto-setup on first InsertEnter
vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = function()
        require("plugins.cmp").setup()
    end,
})

return M
