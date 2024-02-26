return {
  'numToStr/Comment.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  config = function()
    local comment = require 'Comment'
    local opt = {
      opleader = {
        line = 'gc',
        block = 'gb',
      },
      toggler = {
        line = 'gcc',
        block = 'gbc',
      },
      extra = {
        above = 'gcO',
        below = 'gco',
        eol = 'gca',
      },
      mappings = {
        basic = true,
        extra = true,
      },
    }
    comment.setup({ opt })
    local ft = require 'Comment.ft'
    local js_ft = { '//%s', '/**%s*/' }

    ft.javascript = js_ft
  end,
}
