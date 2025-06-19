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
        ["f"] = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          if node.type == "directory" then
            require("fzf-lua").live_grep({ cwd = path })
          else
            require("fzf-lua").live_grep({ cwd = vim.fn.fnamemodify(path, ":h") })
          end
        end,
        ["F"] = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          if node.type == "directory" then
            require("fzf-lua").files({ cwd = path })
          else
            require("fzf-lua").files({ cwd = vim.fn.fnamemodify(path, ":h") })
          end
        end,
      },
      fuzzy_finder_mappings = {
        ["<A-n>"] = "move_cursor_down",
        ["<A-m>"] = "move_cursor_up",
      },
    },
    filesystem = {
      bind_to_cwd = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
      },
    },
  },
}
