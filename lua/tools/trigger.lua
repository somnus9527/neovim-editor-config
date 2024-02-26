local M = {}

M.trigger_user_cmd = function(cmd_name)
  vim.api.nvim_command('doautocmd User ' .. cmd_name)
end

return M
