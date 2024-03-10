local group = vim.api.nvim_create_augroup('SomnusWorkspaceSession', { clear = true })

vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
  group = group,
  callback = function()
    local is_ss_ok, sessions = pcall(require, 'sessions')
    if not is_ss_ok then
      vim.notify 'Sessions Plugin Got Error!'
      return
    end
    local const = require 'tools.const'
    local workspace_tools = require 'tools.workspace'
    local path = const.session_base_path
      .. const.path_separator
      .. workspace_tools.dir_to_workspace_filename(vim.loop.cwd())
    sessions.save(path)
  end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
  group = group,
  pattern = 'LazyLoad',
  callback = function(opts)
    if opts.data == 'workspaces.nvim' then
      local workspaces = require 'workspaces'
      local workspace_tools = require 'tools.workspace'
      local tools = require 'tools.tools'
      local maybe_filename = workspace_tools.dir_to_workspace_filename(vim.loop.cwd())
      local exist = false
      for _, workspace in ipairs(workspaces.get()) do
        if workspace.name == maybe_filename then
          exist = true
        end
      end
      if not exist then
        local contain_pattern = tools.folder_is_contain_patterns()
        if contain_pattern then
          workspaces.add(vim.loop.cwd(), maybe_filename)
        end
      end
    end
  end,
})

-- vim.api.nvim_create_autocmd({ 'DirChanged' }, {
--   group = group,
--   callback = function()
--     vim.notify('DirChanged! The new dir is ' .. vim.loop.cwd())
--     local is_ok, _ = pcall(require, 'neo-tree')
--     if not is_ok then
--       return
--     end
--     -- vim.cmd([[silent! Neotree dir=./ close]])
--   end,
-- })
