return {
  'echasnovski/mini.starter',
  version = '*',
  dependencies = {},
  config = function()
    local starter = require 'mini.starter'
    -- local tools = require 'tools.tools'
    -- local icons = require 'tools.icons'
    local pad = string.rep(' ', 42)
    -- local session_pad = string.rep(' ', 3)
    local new_section = function(name, action, section)
      return { name = name, action = action, section = section }
    end
    local somnus_logo = table.concat({
      "Somnus9527's Neovim Editor",
      '',
      '我从前单听他讲道理，也糊涂过去；现在晓得他讲道理的时候，',
      '不但唇边还抹着人油，而且心里满装着吃人的意思。',
      pad .. '-- <<狂人日记>>',
    }, '\n')
    -- local open_workspace = function(workspace_name)
    --   return function()
    --     if workspaces.name() == workspace_name then
    --       vim.notify('Already in the workspace -> ' .. workspace_name)
    --       return
    --     end
    --     workspaces.open(workspace_name)
    --     starter.close()
    --     vim.notify('Switch workspace to ' .. workspace_name .. 'Successfully!!')
    --   end
    -- end
    -- local action_opt = {
    --   auto_save = true,
    --   silent = false,
    -- }
    -- local load_session = function(workspace_name)
    --   return function()
    --     local session_path = tools.get_session_path(workspace_name)
    --     if workspaces.name() ~= workspace_name then
    --       workspaces.open(workspace_name)
    --     end
    --     sessions.load(session_path, action_opt)
    --     vim.notify('Load Session For Workspace [' .. workspace_name .. '] Successfully!!')
    --   end
    -- end
    -- local get_workspace_item = function()
    --   local workspace_section = {}
    --   local workspace_section_name = icons.Other.Group .. ' Current Workspaces Lists:'
    --   local list = workspaces.get()
    --   for _, info in pairs(list) do
    --     local name = info.name
    --     table.insert(
    --       workspace_section,
    --       new_section(icons.Other.FullArrow .. '. ' .. name, open_workspace(name), workspace_section_name)
    --     )
    --     local session_path = tools.get_session_path(name)
    --     if tools.exist_file(session_path) then
    --       table.insert(
    --         workspace_section,
    --         new_section(
    --           session_pad .. icons.Other.Session .. ' Load Session',
    --           load_session(name),
    --           workspace_section_name
    --         )
    --       )
    --     end
    --   end
    --   return workspace_section
    -- end
    -- local workspace_items = get_workspace_item()
    local workspace_items = {}
    local opts = {
      header = somnus_logo,
      evaluate_single = true,
      items = next(workspace_items) == nil and {
        new_section('New File', 'ene | startinsert', '内置功能'),
        new_section('Quit', 'qa', '内置功能'),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet('░ ', false),
        starter.gen_hook.aligning('center', 'center'),
        -- hook_top_pad_10,
      },
      -- 造成选项也被刷新
      footer = os.date(),
      silent = true,
    }
    starter.setup(opts)
    vim.cmd [[
      augroup MiniStarterJK
        au!
        au User MiniStarterOpened nmap <buffer> j <Cmd>lua MiniStarter.update_current_item('next')<CR>
        au User MiniStarterOpened nmap <buffer> k <Cmd>lua MiniStarter.update_current_item('prev')<CR>
        " au User MiniStarterOpened nmap <buffer> <C-p> <Cmd>Telescope find_files<CR>
        " au User MiniStarterOpened nmap <buffer> <C-n> <Cmd>Telescope file_browser<CR>
      augroup END
    ]]
  end,
}
