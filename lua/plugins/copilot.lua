return {
  'zbirenbaum/copilot.lua',
  module = true,
  enabled = false,
  config = function()
    local copilot = require 'copilot'
    local opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    }
    copilot.setup(opts)
  end,
}
