function LoadSession()
  local is_ok, sessions = pcall(require, 'sessions')
  if not is_ok then
    return
  end
  local const = require 'tools.const'
  local tools = require 'tools.workspace'
  sessions.load(const.session_base_path .. const.path_separator .. tools.dir_to_workspace_filename(vim.loop.cwd()))
end
vim.api.nvim_create_user_command('LoadSession', LoadSession, {})
