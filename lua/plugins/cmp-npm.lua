return {
  'David-Kunz/cmp-npm',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = 'json',
  event = 'VeryLazy',
  config = function()
    require('cmp-npm').setup {}
  end,
}
