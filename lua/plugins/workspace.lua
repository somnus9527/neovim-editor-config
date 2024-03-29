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
    local sessions = require 'sessions'
    local const = require 'tools.const'
    local opts = {
      path = const.workspace_base_path,
      cd_type = 'local',
      auto_open = false,
      notify_info = false,
      hooks = {
        open_pre = {
          'Neotree close',
          'SessionsStop!',
          'silent wall',
          'silent! bufdo bd',
        },
        open = function()
          _G.need_refresh_neotree = true
          vim.schedule(function()
            sessions.load(const.session_base_path .. const.path_separator .. workspace.name(), { silent = true })
          end)
        end,
      },
    }
    workspace.setup(opts)
  end,
}
