return {
  'akinsho/bufferline.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local icons = require "tools.icons"
    require('bufferline').setup {
      options = {
        numbers = 'ordinal',
        separator_style = "thick",
        offsets = {
          {
            filetype = 'neo-tree',
            text = icons.Other.Workspace .. ' File Explorer',
            text_align = 'left',
          },
        },
      },
    }
  end,
}
