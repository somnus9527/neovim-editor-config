return {
  'natecraddock/sessions.nvim',
  dependencies = {
    'natecraddock/workspaces.nvim',
  },
  config = function()
    local sessions = require 'sessions'
    local workspaces = require 'workspaces'
    local utils = require 'utils'
    local opts = {
      events = { 'VimLeavePre', 'VimEnter', 'WinEnter' },
      session_filepath = utils.session_base_path,
      absolute = true,
    }
    sessions.setup(opts)
    local action_opt = {
      auto_save = true,
      silent = false,
    }
    local session_save = function()
      local path = utils.get_session_path(workspaces.name())
      sessions.save(path, action_opt)
    end
    local session_load = function()
      local path = utils.get_session_path(workspaces.name())
      sessions.load(path, action_opt)
    end
    local keymaps = {
      { 'n', '<leader>ss', session_save, { desc = '保存Session' } },
      { 'n', '<leader>sl', session_load, { desc = '加载Session' } },
    }
    utils.set_keymap(keymaps)
    -- 这里自己调一次，因为测试发现该插件定义了事件之后，并不会在事件触发时保存session
    -- 改到workspaces里面出发，这边出发workspaces不一定已经open了，会存错误的session
    -- workspaces里触发又有别的问题。。。，自己写autocmd处理
    -- print(workspaces.name())
    -- session_save()
  end,
}
