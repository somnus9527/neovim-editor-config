return {
  'natecraddock/workspaces.nvim',
  dependencies = {
    'natecraddock/sessions.nvim',
    'nvim-lua/plenary.nvim',
  },
  lazy = false,
  priority = 100,
  config = function()
    local workspace = require 'workspaces'
    local const = require 'tools.const'
    local opts = {
      path = const.workspace_base_path,
      cd_type = 'local',
      auto_open = false,
      notify_info = false,
    }
    workspace.setup(opts)
  end,
}
