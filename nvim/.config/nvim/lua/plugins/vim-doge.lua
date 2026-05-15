-- vim-doge configuration for auto-generating documentation comments
-- Supports 18+ languages with multiple doc standards (Doxygen, JSDoc, ReST, etc.)

-- C/C++ documentation
vim.g.doge_doc_standard_c = "doxygen_c"
vim.g.doge_doc_standard_cpp = "doxygen_c"

-- Python documentation (reST, NumPy, Google, Sphinx, Doxygen)
vim.g.doge_doc_standard_python = "google"

-- Lua documentation (LDoc)
vim.g.doge_doc_standard_lua = "ldoc"

-- JavaScript/TypeScript documentation (JSDoc)
vim.g.doge_doc_standard_javascript = "jsdoc"
vim.g.doge_doc_standard_typescript = "jsdoc"

-- Rust documentation (RustDoc)
vim.g.doge_doc_standard_rs = "rustdoc"

-- Java documentation (JavaDoc)
vim.g.doge_doc_standard_java = "javadoc"

-- Bash documentation (Google style)
vim.g.doge_doc_standard_sh = "google"

-- Ruby documentation (YARD)
vim.g.doge_doc_standard_ruby = "YARD"

-- Disable default mappings (we'll create custom ones via keymap-helper)
vim.g.doge_mapping = ""

-- Enable interactive mode (Tab/Shift-Tab to jump between TODO placeholders)
vim.g.doge_comment_interactive = 1
