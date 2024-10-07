return {
  'utilyre/barbecue.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  name = 'barbecue',
  dependencies = {
    'SmiteshP/nvim-navic',
    'nvim-tree/nvim-web-devicons', -- optional dependency
  },
}
