return {
  'echasnovski/mini.splitjoin',
  event = { 'BufNewFile', 'BufReadPre' },
  config = function()
    local splitjoin = require 'mini.splitjoin'
    local opt = {
      mappings = {
        toggle = 'qs'
      }
    }
    splitjoin.setup(opt)
  end
}
