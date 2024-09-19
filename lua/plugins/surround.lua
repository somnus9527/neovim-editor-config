return {
  "echasnovski/mini.surround",
  opts = {
    mappings = {
      add = "sa", -- Add surrounding in Normal and Visual modes
      delete = "sd", -- Delete surrounding
      replace = "sr", -- Replace surrounding
    },
  },
  keys = {
    { "s", "", desc = "+surround/move" },
  },
}
