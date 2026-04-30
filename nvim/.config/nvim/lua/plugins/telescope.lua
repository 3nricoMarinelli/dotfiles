require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = "delete_buffer",
      },
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      find_command = {
        "fd",
        "--type",
        "f",
        "--hidden",
        "--follow",
        "--exclude",
        ".git",
      },
    },
    live_grep = {
      theme = "dropdown",
      additional_args = { "--hidden", "--follow", "--glob", "!.git" },
    },
    grep_string = {
      theme = "dropdown",
    },
  },
})
