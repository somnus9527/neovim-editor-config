-- noice.nvim: 安全模式（尽量不接管交互确认）
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  enabled = true,
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- notify 变为可选依赖，按需加载
    "rcarriga/nvim-notify",
  },
  opts = {
    -- 放开命令行输入接管
    cmdline = {
      enabled = true,
    },
    -- 不接管消息事件，降低与交互确认冲突的概率
    messages = {
      enabled = false,
    },
    -- 不接管补全菜单
    popupmenu = {
      enabled = false,
    },
    -- 禁用消息重定向
    redirect = {
      enabled = false,
    },
    -- 不改造确认弹窗
    confirm = {
      enabled = false,
    },
    -- 仅保留 notify 能力
    notify = {
      enabled = true,
      view = "notify",
    },
    -- 放开 Noice 的 LSP 相关显示能力
    lsp = {
      progress = {
        enabled = true,
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
      },
      signature = {
        enabled = true,
      },
      message = {
        enabled = true,
      },
    },
    -- 关闭路由规则，避免额外的事件接管
    routes = {},
    presets = {
      bottom_search = false,
      command_palette = false,
      long_message_to_split = false,
      inc_rename = false,
      lsp_doc_border = true,
    },
    throttle = 1000 / 30,
    views = {},
  },
  config = function(_, opts)
    require("noice").setup(opts)

    -- 配置 nvim-notify，减少干扰
    require("notify").setup({
      background_colour = "#000000",
      fps = 60,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = "",
      },
      level = vim.log.levels.WARN,  -- 提高级别：只显示警告及以上
      minimum_width = 30,
      render = "compact",            -- 紧凑渲染
      stages = "slide",              -- 简单动画
      timeout = 3000,
      top_down = false,              -- 从底部弹出，不遮挡编辑区域
    })
  end,
  keys = {
    { "<localleader>nh", "<cmd>Noice history<cr>", desc = "显示消息历史 (Noice)" },
    { "<localleader>nl", "<cmd>Noice last<cr>", desc = "显示最后消息 (Noice)" },
    { "<localleader>nd", "<cmd>Noice dismiss<cr>", desc = "关闭通知 (Noice)" },
    { "<localleader>ne", "<cmd>Noice errors<cr>", desc = "显示错误 (Noice)" },
  },
}
