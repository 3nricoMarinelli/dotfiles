local wk = require("which-key")
wk.add({
	-- Misc
	{ "<leader>p", desc = "toggle theme" },
	{ "<leader>u", desc = "open url" },
	{ "<leader>z", desc = "floating terminal" },
	{ "<leader>w", desc = "write file" },
	{ "<leader>W", desc = "toggle wrap" },
	{ "<leader>R", desc = "replace all" },
	{ "<leader>nn", desc = "toggle relative nums" },
	{ "<leader>P", desc = "plugins sync (lazy)" },
	{ "<leader>i", desc = "auto indent" },

	-- Buffers
	{ "<leader>q", desc = "close buffer" },
	{ "<leader>Q", desc = "force quit nvim" },
	{ "<leader>U", desc = "close ALL buffers" },
	{ "<leader>v", desc = "vsplit next buf" },

	-- File tree
	{ "<leader>t", desc = "toggle tree" },
	{ "<leader>tl", desc = "toggle linting" },
	{ "T", desc = "toggle tree" },

	-- Telescope (file finding)
	{ "<leader>f", group = "telescope" },
	{ "<leader>Fh", desc = "files home" },
	{ "<leader>Fc", desc = "files .config" },
	{ "<leader>Fl", desc = "files .local/src" },
	{ "<leader>Ff", desc = "files parent" },
	{ "<leader>Fr", desc = "resume" },

	-- Search/replace
	{ "<leader>s", group = "search/replace" },

	-- Comments
	{ "<leader>/", desc = "comment line" },
	{ "<leader>?", desc = "comment block" },

	-- Git + Grep
	{ "<leader>g", group = "git/grep" },
	{ "<leader>gg", desc = "grep" },
	{ "<leader>gw", desc = "grep under cursor" },
	{ "<leader>gs", desc = "git status" },
	{ "<leader>gc", desc = "git commit" },
	{ "<leader>gu", desc = "git pull" },
	{ "<leader>gp", desc = "git push" },
	{ "<leader>gd", desc = "diff open" },
	{ "<leader>gD", desc = "diff close" },
	{ "<leader>gh", desc = "file history" },
	{ "<leader>ga", desc = "stage hunk" },
	{ "<leader>gU", desc = "undo stage hunk" },
	{ "<leader>gr", desc = "reset hunk" },
	{ "<leader>gv", desc = "preview hunk" },
	{ "<leader>gb", desc = "blame line" },
	{ "<leader>gj", desc = "next hunk" },
	{ "<leader>gk", desc = "prev hunk" },

	-- LSP (unified across all languages)
	{ "<leader>l", group = "LSP" },
	{ "<leader>ld", desc = "definition" },
	{ "<leader>lD", desc = "declaration" },
	{ "<leader>lk", desc = "signature" },
	{ "<leader>la", desc = "code action" },
	{ "<leader>lr", desc = "references" },
	{ "<leader>li", desc = "implementations" },
	{ "<leader>lt", desc = "type definition" },
	{ "<leader>lx", desc = "diagnostics" },
	{ "<leader>ls", desc = "workspace symbols" },
	{ "<leader>r", desc = "rename" },

	-- C/C++ tools
	{ "<leader>c", group = "C/C++" },
	{ "<leader>cg", desc = "cmake generate" },
	{ "<leader>cb", desc = "cmake build" },
	{ "<leader>ct", desc = "gtest run" },

	-- Typst
	{ "<leader>tc", desc = "typst compile" },
	{ "<leader>tw", desc = "typst watch" },

	-- Python debugging
	{ "<leader>p", group = "python" },
	{ "<leader>pb", desc = "add breakpoint()" },
	{ "<leader>pB", desc = "delete breakpoints" },

	-- DAP debugger
	{ "<leader>d", group = "debug" },
	{ "<leader>db", desc = "toggle breakpoint" },
	{ "<leader>dc", desc = "continue" },
	{ "<leader>do", desc = "step over" },
	{ "<leader>di", desc = "step into" },
	{ "<leader>dO", desc = "step out" },
	{ "<leader>dq", desc = "terminate" },
	{ "<leader>du", desc = "toggle UI" },

	-- Molten (Jupyter)
	{ "<leader>m", group = "molten" },
	{ "<leader>mi", desc = "init kernel" },
	{ "<leader>mc", desc = "run cell" },
	{ "<leader>me", desc = "evaluate" },
	{ "<leader>ml", desc = "eval line" },
	{ "<leader>mr", desc = "re-evaluate" },
	{ "<leader>mo", desc = "output window" },
	{ "<leader>mx", desc = "interrupt kernel" },
	{ "<leader>mq", desc = "deinit kernel" },
	{ "<leader>md", desc = "delete output" },

	-- Opencode
	{ "<leader>o", group = "opencode" },
	{ "<leader>ot", desc = "toggle embedded" },
	{ "<leader>oa", desc = "ask about this" },
	{ "<leader>o+", desc = "add to prompt" },
	{ "<leader>oe", desc = "explain code" },
	{ "<leader>on", desc = "new session" },
	{ "<leader>os", desc = "select prompt" },
})
