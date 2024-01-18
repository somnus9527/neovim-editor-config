return {
  'David-Kunz/cmp-npm',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = 'json',
  lazy = true,
  config = function()
    require('cmp-npm').setup {}
  end,
}
