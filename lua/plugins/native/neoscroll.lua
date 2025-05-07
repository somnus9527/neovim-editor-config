return {
  "karb94/neoscroll.nvim",
  event = { "BufNewFile", "BufReadPre" },
  config = function()
    local neoscroll = require("neoscroll")
    local keymap = {
      ["<A-1>"] = function()
        neoscroll.scroll(0.8, { move_cursor = true, duration = 100 })
      end,
      ["<A-2>"] = function()
        neoscroll.scroll(-0.8, { move_cursor = true, duration = 100 })
      end,
    }
    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
