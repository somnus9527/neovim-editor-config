return {
  "folke/flash.nvim",
  keys = {
    { "S", mode = { "n", "x", "o" }, false },
    { "s", mode = { "n", "x", "o" }, false },
    { "ss", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  },
}
