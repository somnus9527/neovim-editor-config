return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      symbols = {
        win = {
          size = 100,
          position = 'right'
        }
      }
    },
  },
  keys = {
    { "<leader>cs", false },
    { "<leader>cs", "<cmd>Trouble symbols toggle focus=true<cr>", desc = "Symbols(Symbols Trouble)"},
  }
}
