return {
  'stevearc/dressing.nvim',
  config = function()
    local dressing = require 'dressing'
    local opts = {}
    dressing.setup(opts)
  end
}
