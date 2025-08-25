return {
  "folke/trouble.nvim",
  event = 'VeryLazy',
  opts = {
    modes = {
      symbols = {
        win = {
          size = 100,
          position = 'right'
        }
      }
    },
    keys = {
      o = nil,
      ["<cr>"] = "jump_close",
    }
  },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "当前Buffer的Diagnostics"},
    { "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>", desc = "当前Workspace的Diagnostics"},
  }
}
