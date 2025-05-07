return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    { "<leader>e", false },
    { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
  },
  opts = {
    close_if_last_window = true,
    window = {
      position = "left",
      width = 80,
      mappings = {
        ["s"] = "none",
        ["S"] = "none",
      },
      fuzzy_finder_mappings = {
        ["<A-n>"] = "move_cursor_down",
        ["<A-m>"] = "move_cursor_up",
      }
    },
    filesystem = {
      bind_to_cwd = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
      }
    }
  }
}
