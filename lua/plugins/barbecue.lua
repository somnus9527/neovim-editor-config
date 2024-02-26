local tools = require 'tools.tools'
local conf = tools.load_conf()
return {
  'utilyre/barbecue.nvim',
  event = 'BufEnter',
  name = 'barbecue',
  dependencies = {
    'SmiteshP/nvim-navic',
    'nvim-tree/nvim-web-devicons', -- optional dependency
  },
  opts = {
    theme = conf.default.colorscheme
  }
}
