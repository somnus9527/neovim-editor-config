return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- keymaps = {
      --   visual = "S", -- 保持默认
      --   delete = "ds", -- 删除操作
      --   change = "cs", -- 替换操作
      -- },
      -- aliases = {
      --   ["b"] = ")", -- 默认已存在
      --   ["m"] = "**", -- 自定义 Markdown 加粗
      --   ["c"] = { -- 支持函数动态生成符号
      --     { "```", "```" }, -- 输入 `c` 生成代码块
      --   },
      -- },
      move_cursor = false, -- 光标在包围符号开头
      highlight = {
        duration = 300, -- 缩短高亮时间
        hl_group = "IncSearch", -- 高亮颜色设为搜索匹配色
      },
    })
  end,
}
