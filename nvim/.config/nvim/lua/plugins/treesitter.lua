local parsers = {
  "bash",
  "c",
  "cmake",
  "cpp",
  "go",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "tsx",
  "typescript",
  "typst",
}

require("nvim-treesitter").setup({
  ensure_installed = parsers,
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})
