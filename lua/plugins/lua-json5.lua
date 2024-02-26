return {
  'Joakker/lua-json5',
  lazy = true,
  build = function()
    local const = require 'tools.const'
    if const.is_windows then
      os.execute [[powershell.exe -file .\install.ps1]]
    else
      os.execute './install.sh'
    end
  end,
  module = true,
}
