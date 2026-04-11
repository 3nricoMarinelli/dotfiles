-- neo-tree.nvim: File tree navigator
-- Modern replacement for nvim-tree with better UX and flexibility

require("neo-tree").setup({
	close_if_last_window = false, -- keep neo-tree open even if it's the last window
	popup_border_style = "rounded",
	clipboard = {
		sync = "none", -- none, global, universal
	},
	enable_git_status = true,
	enable_diagnostics = true,
	open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
	open_files_using_relative_paths = false,
	sort_case_insensitive = false,

	-- Component configuration
	default_component_configs = {
		container = {
			enable_character_fade = true,
		},
		indent = {
			indent_size = 2,
			padding = 1,
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
			highlight = "NeoTreeIndentMarker",
			with_expanders = nil,
			expander_collapsed = "",
			expander_expanded = "",
			expander_highlight = "NeoTreeExpander",
		},
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "󰜌",
			-- Use nvim-web-devicons if available
			provider = function(icon, node, state)
				if node.type == "file" or node.type == "terminal" then
					local success, web_devicons = pcall(require, "nvim-web-devicons")
					local name = node.type == "terminal" and "terminal" or node.name
					if success then
						local devicon, hl = web_devicons.get_icon(name)
						icon.text = devicon or icon.text
						icon.highlight = hl or icon.highlight
					end
				end
			end,
			default = "*",
			highlight = "NeoTreeFileIcon",
			use_filtered_colors = true,
		},
		modified = {
			symbol = "[+]",
			highlight = "NeoTreeModified",
		},
		name = {
			trailing_slash = false,
			use_filtered_colors = true,
			use_git_status_colors = true,
			highlight = "NeoTreeFileName",
		},
		git_status = {
			symbols = {
				added = "",
				modified = "",
				deleted = "✖",
				renamed = "󰁕",
				untracked = "",
				ignored = "",
				unstaged = "󰄱",
				staged = "",
				conflict = "",
			},
		},
	},

	-- Window layout
	window = {
		position = "left",
		width = 30,
		mapping_options = {
			noremap = true,
			nowait = true,
		},
		mappings = {
			["<space>"] = {
				"toggle_node",
				nowait = false,
			},
			["<2-LeftMouse>"] = "open",
			["<cr>"] = "open",
			["<esc>"] = "cancel",
			["P"] = {
				"toggle_preview",
				config = { use_float = true },
			},
			["l"] = "focus_preview",
			["S"] = "open_split",
			["s"] = "open_vsplit",
			-- ["<C-t>"] = "open_tabnew", -- disabled due to neo-tree bug with nil tree
			["w"] = "open_with_window_picker",
			["C"] = "close_node",
			["z"] = "close_all_nodes",
			["a"] = {
				"add",
				config = { show_path = "none" },
			},
			["A"] = "add_directory",
			["d"] = "delete",
			["r"] = "rename",
			["b"] = "rename_basename",
			["y"] = "copy_to_clipboard",
			["x"] = "cut_to_clipboard",
			["p"] = "paste_from_clipboard",
			["<C-r>"] = "clear_clipboard",
			["c"] = "copy",
			["m"] = "move",
			["q"] = "close_window",
			["R"] = "refresh",
			["?"] = "show_help",
			["<"] = "prev_source",
			[">"] = "next_source",
			["i"] = "show_file_details",
		},
	},

	-- Filesystem source
	filesystem = {
		filtered_items = {
			visible = false,
			hide_dotfiles = true,
			hide_gitignored = true,
			hide_ignored = true,
			ignore_files = {
				".neotreeignore",
				".ignore",
			},
			hide_hidden = true,
			hide_by_name = {},
			hide_by_pattern = {},
			always_show = {},
			always_show_by_pattern = {},
			never_show = {},
			never_show_by_pattern = {},
		},
		follow_current_file = {
			enabled = true, -- Highlight current file when tree is open
			leave_dirs_open = false,
		},
		group_empty_dirs = false,
		hijack_netrw_behavior = "open_default",
		use_libuv_file_watcher = false,
		window = {
			mappings = {
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["H"] = "toggle_hidden",
				["/"] = "fuzzy_finder",
				["D"] = "fuzzy_finder_directory",
				["#"] = "fuzzy_sorter",
				["f"] = "filter_on_submit",
				["<c-x>"] = "clear_filter",
				["[g"] = "prev_git_modified",
				["]g"] = "next_git_modified",
				["o"] = {
					"show_help",
					nowait = false,
					config = { title = "Order by", prefix_key = "o" },
				},
				["oc"] = { "order_by_created", nowait = false },
				["od"] = { "order_by_diagnostics", nowait = false },
				["og"] = { "order_by_git_status", nowait = false },
				["om"] = { "order_by_modified", nowait = false },
				["on"] = { "order_by_name", nowait = false },
				["os"] = { "order_by_size", nowait = false },
				["ot"] = { "order_by_type", nowait = false },
			},
			fuzzy_finder_mappings = {
				["<down>"] = "move_cursor_down",
				["<C-n>"] = "move_cursor_down",
				["<up>"] = "move_cursor_up",
				["<C-p>"] = "move_cursor_up",
				["<esc>"] = "close",
				["<C-CR>"] = "close_clear_filter",
			},
		},
		commands = {},
	},

	-- Buffers source
	buffers = {
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		group_empty_dirs = true,
		show_unloaded = true,
		window = {
			mappings = {
				["d"] = "buffer_delete",
				["bd"] = "buffer_delete",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
			},
		},
	},

	-- Git status source
	git_status = {
		window = {
			position = "float",
			mappings = {
				["A"] = "git_add_all",
				["gu"] = "git_unstage_file",
				["ga"] = "git_add_file",
				["gr"] = "git_revert_file",
				["gc"] = "git_commit",
				["gp"] = "git_push",
			},
		},
	},
})

-- Keybindings are managed centrally in lua/config/mappings.lua
