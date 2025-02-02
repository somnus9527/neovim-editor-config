return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["s"] = "none",
        ["S"] = "none",
      },
      fuzzy_finder_mappings = {
        ["<A-n>"] = "move_cursor_down",
        ["<A-m>"] = "move_cursor_up",
      }
    }
  }
}
