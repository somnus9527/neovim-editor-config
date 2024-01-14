return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local icons = require "configs.icons"
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
