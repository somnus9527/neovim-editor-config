return {
  'Joakker/lua-json5',
  build = function()
    local utils = require 'utils'
    if utils.is_windows then
      return 'powershell ./install.ps1'
    else
      return './install.sh'
    end
  end,
  module = true,
  -- run = './install.sh'
}
