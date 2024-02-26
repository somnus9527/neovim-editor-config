return {
  'echasnovski/mini.indentscope',
  event = { 'BufNewFile', 'BufReadPre' },
  config = function()
    require('mini.indentscope').setup {}
  end,
}
