return {
  'echasnovski/mini.indentscope',
  event = 'InsertCharPre',
  config = function()
    require('mini.indentscope').setup {}
  end,
}
