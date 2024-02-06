local group = vim.api.nvim_create_augroup('SomnusSessions', { clear = true })
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = function()
    local sessions = require 'sessions'
    local workspaces = require 'workspaces'
    local utils = require 'utils'
    local session_path = utils.get_session_path(workspaces.name())
    local action_opt = {
      auto_save = true,
      silent = false,
    }
    sessions.save(session_path, action_opt)
  end,
})
