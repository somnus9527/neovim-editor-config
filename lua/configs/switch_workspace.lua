local is_ok, fzf = pcall(require, 'fzf-lua')

if not is_ok then
  return
end

local is_wk_ok, workspaces = pcall(require, 'workspaces')
if not is_wk_ok then
  return
end
local tools = require 'tools.tools'

_G.SwitchWorkspace = function()
  local workspace_tools = require 'tools.workspace'
  local workspaces_lists = workspaces.get()
  local items = {}
  for _, workspace in ipairs(workspaces_lists) do
    local workspace_dir = workspace_tools.workspace_filename_to_dir(workspace.name)
    local item_text = workspace_dir == vim.loop.cwd() and workspace_dir .. ' (当前项目)' or workspace_dir
    table.insert(items, item_text)
  end
  fzf.fzf_exec(items, {
    prompt = 'SwitchWorkspace> ',
    actions = {
      ['default'] = function(selected)
        local val = selected[1]
        local name = workspace_tools.dir_to_workspace_filename(val)
        workspaces.open(name)
        _G.need_refresh_neotree = true
      end,
    },
  })
end

local keymaps = {
  { 'n', '<leader>p', '<CMD>lua SwitchWorkspace()<CR>', { desc = '切换Workspace' } },
}

tools.set_keymap(keymaps)
