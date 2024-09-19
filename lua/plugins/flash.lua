return {
  "folke/flash.nvim",
  keys = {
    { "s", false },
    { "S", false },
    { "ss", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "sS", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  }
}
