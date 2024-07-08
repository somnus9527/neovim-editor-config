return {
  'folke/noice.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    local tools = require 'tools.tools'
    local opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
        hover = {
          -- js这种会同时存在多个server的,会出现一个有信息一个没有,这时候就会Hover有提示,但是同时也会提示No Information Available
          silent = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = false,
        lsp_doc_border = false,
      },
      popupmenu = {
        -- 直接使用cmp的menu,不然一按tab会出现两个menu
        backend = 'cmp',
      },
      routes = {
        tools.myMiniView 'Already at .* change',
        tools.myMiniView 'written',
        tools.myMiniView 'yanked',
        tools.myMiniView 'more lines?',
        tools.myMiniView 'fewer lines?',
        tools.myMiniView('fewer lines?', 'lua_error'),
        tools.myMiniView 'change; before',
        tools.myMiniView 'change; after',
        tools.myMiniView 'line less',
        tools.myMiniView 'lines indented',
        tools.myMiniView 'Messages: Some options have changed',
        tools.myMiniView 'No lines in buffer',
        tools.myMiniView('search hit .*, continuing at', 'wmsg'),
        tools.myMiniView('E486: Pattern not found', 'emsg'),
        -- 和第二条一致,都是不显示写入文件成功的提示,但是我的提示是中文的已写入...,所以加这么一条
        tools.myMiniView '已写入',
      },
    }
    local notify = require 'noice'
    notify.setup(opts)
  end,
}
