return {
  'natecraddock/workspaces.nvim',
  event = 'VeryLazy',
  config = function()
    local workspaces = require 'workspaces'
    local tools = require 'tools.tools'
    local opts = {
      path = vim.fn.stdpath 'data' .. '/workspaces',
      auto_open = true,
      -- hooks = {
      --   open = function()
      --     local is_ok, sessions = pcall(require, 'sessions')
      --     if is_ok then
      --       local session_base_path = vim.fn.stdpath 'data' .. '/sessions/'
      --       local file_name = '.session'
      --       local workspace_name = workspaces.name()
      --       if workspace_name then
      --         file_name = '.' .. workspace_name .. '_session'
      --       end
      --       local final_path = session_base_path .. file_name
      --       sessions.save(final_path, {
      --         auto_save = true,
      --         silent = false,
      --       })
      --     end
      --   end,
      -- },
    }
    workspaces.setup(opts)
    local add_workspace = function()
      local root_dir = vim.loop.cwd()
      local workspace_name = vim.fn.input('Please enter workspace name: ', '')
      if workspace_name == nil or workspace_name == '' then
        vim.notify 'Workspace名称不能为空!'
        return
      end
      workspaces.add(root_dir, workspace_name)
    end
    local remove_workspace = function()
      local workspace_name = vim.fn.input('Please enter workspace name: ', '')
      if workspace_name == nil or workspace_name == '' then
        vim.notify 'Workspace名称不能为空!'
        return
      end
      workspaces.remove(workspace_name)
    end
    local rename_workspace = function()
      local old_name = vim.fn.input('Please enter old name: ', '')
      if old_name == nil or old_name == '' then
        vim.notify '原名称不能为空!'
        return
      end
      local new_name = vim.fn.input('Please enter new name: ', '')
      if new_name == nil or new_name == '' then
        vim.notify '新名称不能为空!'
        return
      end
      workspaces.rename(old_name, new_name)
    end
    local open_workspace = function()
      local name = vim.fn.input('Please enter name: ', '')
      if name == nil or name == '' then
        vim.notify '名称不能为空!'
        return
      end
      workspaces.open(name)
    end
    local keymaps = {
      { 'n', '<leader>wa', add_workspace, { desc = '添加具名Workspace' } },
      { 'n', '<leader>wx', remove_workspace, { desc = '删除具名Workspace' } },
      { 'n', '<leader>wr', rename_workspace, { desc = '重命名具名Workspace' } },
      { 'n', '<leader>wo', open_workspace, { desc = '打开具名Workspace' } },
    }
    tools.set_keymap(keymaps)
  end,
}
