-- 这个插件解决了当jk映射为esc时，插入模式输入j会有延迟的问题
return {
  "max397574/better-escape.nvim",
  event = "InsertCharPre",
  config = function()
    require("better_escape").setup({
      timeout = vim.o.timeoutlen or 300,
      mapping = { "jk" },
    })
  end,
}
