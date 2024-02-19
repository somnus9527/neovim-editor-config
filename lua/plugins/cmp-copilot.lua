return {
  'zbirenbaum/copilot-cmp',
  module = true,
  enabled = false,
  dependencies = {
    'zbirenbaum/copilot.lua',
  },
  config = function()
    local copilot = require 'copilot_cmp'
    local opts = {
      event = { 'InsertEnter', 'LspAttach' },
      fix_pairs = true,
    }
    copilot.setup(opts)
  end,
}
