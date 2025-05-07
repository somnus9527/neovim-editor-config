return {
  "folke/flash.nvim",
  vscode = true,
  keys = {
    { "S", mode = { "n", "x", "o" }, false }, -- 禁用 Shift+S（可能是别的用途）
    { "s", mode = { "n", "x", "o" }, false }, -- 禁用默认绑定（重设）
    { "ss", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  },
}