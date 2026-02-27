-- noice.nvim: 美化命令行、消息、弹窗UI，解决确认提示被忽略导致卡住的问题
-- 文档: https://github.com/folke/noice.nvim
return {
  "folke/noice.nvim",
  -- 尽早加载，确保能接管所有UI消息
  event = "VeryLazy",
  dependencies = {
    -- 依赖 nui.nvim 作为UI组件库
    "MunifTanjim/nui.nvim",
    -- 可选: nvim-notify 用于通知消息
    "rcarriga/nvim-notify",
  },
  opts = {
    -- 命令行配置
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      opts = {},
      format = {
        -- 命令行类型配置
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        input = {},
      },
    },
    -- 消息配置
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },
    -- 弹窗配置
    popupmenu = {
      enabled = true,
      backend = "nui",
      kind_icons = {},
    },
    -- 通知配置
    redirect = {
      view = "popup",
      filter = { event = "msg_show" },
    },
    -- 命令执行提示
    commands = {
      history = {
        view = "split",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
      },
      last = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
        filter_opts = { count = 1 },
      },
      errors = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { error = true },
        filter_opts = { reverse = true },
      },
    },
    -- 确认提示配置 - 这是解决卡住问题的关键
    confirm = {
      enabled = true,
      view = "confirm",
    },
    -- 通知窗口配置
    notify = {
      enabled = true,
      view = "notify",
    },
    -- LSP进度消息
    lsp = {
      progress = {
        enabled = true,
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30,
        view = "mini",
      },
      override = {
        -- 覆盖内置的 LSP 消息处理
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
        opts = {},
      },
      message = {
        enabled = true,
        view = "notify",
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
    -- Markdown 渲染
    markdown = {
      hover = {
        ["|(%S-)|"] = vim.cmd.help,
        ["%[.-%]%((%S-)%)"] = function(url) require("noice.util").open(url) end,
      },
      highlights = {
        ["|%S-|"] = "@text.reference",
        ["@%S+"] = "@parameter",
        ["^%s*(Parameters:)"] = "@text.title",
        ["^%s*(Return:)"] = "@text.title",
        ["^%s*(See also:)"] = "@text.title",
        ["{%S-}"] = "@parameter",
      },
    },
    -- 健康检查
    health = {
      checker = true,
    },
    -- 智能搜索
    smart_move = {
      enabled = true,
      excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
    },
    -- 预设配置
    presets = {
      -- 使用底部命令行
      bottom_search = false,
      -- 使用命令行弹窗
      command_palette = true,
      -- 长消息自动滚动
      long_message_to_split = true,
      -- 智能包裹
      inc_rename = false,
      -- LSP 文档边框
      lsp_doc_border = true,
    },
    -- 缩略图配置
    throttle = 1000 / 30,
    views = {},
    routes = {},
    -- 状态栏组件
    status = {},
    -- 格式配置
    format = {},
  },
  config = function(_, opts)
    require("noice").setup(opts)

    -- 配置 nvim-notify
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
      level = 2,
      minimum_width = 50,
      render = "default",
      stages = "fade_in_slide_out",
      timeout = 3000,
      top_down = true,
    })
  end,
  -- 按键映射
  keys = {
    -- 显示消息历史
    { "<leader>nh", "<cmd>Noice history<cr>", desc = "显示消息历史 (Noice)" },
    -- 显示最后一条消息
    { "<leader>nl", "<cmd>Noice last<cr>", desc = "显示最后消息 (Noice)" },
    -- 关闭所有通知
    { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "关闭通知 (Noice)" },
    -- 显示错误
    { "<leader>ne", "<cmd>Noice errors<cr>", desc = "显示错误 (Noice)" },
  },
}

