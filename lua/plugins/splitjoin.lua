return {
  'echasnovski/mini.splitjoin',
  event = 'BufEnter',
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
