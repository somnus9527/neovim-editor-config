return {
  'code-biscuits/nvim-biscuits',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  event = { 'BufNewFile', 'BufReadPre' },
  config = function()
    local biscuits = require 'nvim-biscuits'
    local icons = require 'tools.icons'
    local opts = {
      default_config = {
        max_length = 60,
        min_distance = 5,
        prefix_string = ' ' .. icons.biscuits.Prefix .. ' ',
      },
      on_events = { 'InsertLeave', 'CursorHoldI' },
      language_config = {
        html = {
          prefix_string = ' ' .. icons.biscuits.Html .. ' ',
        },
        javascript = {
          prefix_string = ' ' .. icons.biscuits.Javascript .. ' ',
          max_length = 80,
        },
        lua = {
          prefix_string = ' ' .. icons.Menu.nvim_lua .. ' ',
        },
        python = {
          disabled = true,
        },
      },
    }
    biscuits.setup(opts)
  end,
}
