return {
  'natecraddock/sessions.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  lazy = true,
  module = true,
  config = function()
    local sessions = require 'sessions'
    local const = require 'tools.const'
    local opts = {
      events = { 'VimLeavePre' },
      session_filepath = const.session_base_path,
      absolute = true,
    }
    sessions.setup(opts)
  end,
}
