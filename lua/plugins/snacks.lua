return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<A-n>"] = { "list_down", mode = { "i", "n" } },
            ["<A-m>"] = { "list_up", mode = { "i", "n" } },
            ["<A-e>"] = { "close", mode = { "i", "n" } },
            ["<A-,>"] = { "list_scroll_down", mode = { "i", "n" } },
            ["<A-.>"] = { "list_scroll_up", mode = { "i", "n" } },
            ["<A-k>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<A-j>"] = { "preview_scroll_down", mode = { "i", "n" } },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>.", false },
    { "<leader>/", false },
    { "<leader>,", false },
  }
}
