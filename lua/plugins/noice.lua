-- noice.nvim: 美化命令行、消息、弹窗UI
-- 已优化：仅保留错误/警告通知，减少干扰
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- notify 变为可选依赖，按需加载
    "rcarriga/nvim-notify",
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
      },
    },
    -- 关键修改：普通消息不再走 notify，仅错误/警告走 notify
    messages = {
      enabled = true,
      view = "mini",           -- 普通消息用 mini 视图（右下角短暂显示）
      view_error = "notify",   -- 错误用通知
      view_warn = "mini",    -- 警告用通知
      view_history = "messages",
      view_search = false,     -- 禁用搜索计数通知
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    -- 禁用 redirect 到 popup
    redirect = {
      view = "mini",
      filter = { event = "msg_show" },
    },
    -- 确认提示配置
    confirm = {
      enabled = true,
      view = "confirm",
    },
    notify = {
      enabled = true,
      view = "notify",
    },
    -- LSP 配置优化
    lsp = {
      progress = {
        enabled = true,
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30,
        view = "mini",         -- LSP 进度用 mini 视图
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
        silent = false,
        view = nil,
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          luasnip = true,
          throttle = 50,
        },
        view = nil,
      },
      -- 关键修改：LSP 消息不再走 notify
      message = {
        enabled = true,
        view = "mini",         -- LSP 消息用 mini 视图
        opts = {},
      },
      documentation = {
        view = "hover",
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
    },
    -- 添加路由规则，过滤掉不必要的消息
    routes = {
      -- 忽略 "written" 文件保存消息
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
      -- 忽略 "已写入" 中文保存消息
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "已写入",
        },
        opts = { skip = true },
      },
      -- 忽略行数显示（如 "10 lines yanked"）
      {
        filter = {
          event = "msg_show",
          find = "lines? yanked",
        },
        view = "mini",
      },
      -- 忽略 undo/redo 消息
      {
        filter = {
          event = "msg_show",
          find = "^%d+ changes?;",
        },
        opts = { skip = true },
      },
      -- 忽略搜索命中数（如果你不需要）
      {
        filter = {
          event = "msg_show",
          kind = "search_count",
        },
        opts = { skip = true },
      },
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = true,
    },
    throttle = 1000 / 30,
    views = {
      -- mini 视图配置（右下角小浮窗，不干扰）
      mini = {
        win_options = {
          winblend = 0,
        },
      },
    },
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
    { "<leader>nh", "<cmd>Noice history<cr>", desc = "显示消息历史 (Noice)" },
    { "<leader>nl", "<cmd>Noice last<cr>", desc = "显示最后消息 (Noice)" },
    { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "关闭通知 (Noice)" },
    { "<leader>ne", "<cmd>Noice errors<cr>", desc = "显示错误 (Noice)" },
  },
}

