local get_opts = function()
  -- 定义一个自定义高亮组的颜色
  local header = { opts = { hl = 'Operator', position = 'center' }, type = 'text', val = {} }
  local pad = string.rep(' ', 18)
  header.val = {
    '',
    '',
    '',
    "Somnus9527's Neovim Editor",
    '',
    '我从前单听他讲道理，也糊涂过去;',
    '现在晓得他讲道理的时候，',
    '不但唇边还抹着人油，',
    '而且心里满装着吃人的意思。',
    pad .. '-- <<狂人日记>>',
  }
  local footer = { opts = { hl = 'Special', position = 'center' }, type = 'text', val = {} }
  local projects = {
    type = 'group',
    val = {
      { type = 'padding', val = 1 },
      { type = 'text', val = '现有项目列表:', opts = { hl = 'Exception', position = 'center' } },
      { type = 'padding', val = 1 },
      { type = 'group', val = { { type = 'group', val = {}, opts = { spacing = 1 } } } },
    },
  }
  local lazystats = { type = 'group', val = {} }

  local workspaces = require 'workspaces'
  local workspaces_lists = workspaces.get()
  local workspace_tools = require 'tools.workspace'
  -- local sessions = require 'sessions'
  -- local const = require 'tools.const'
  for i, workspace in ipairs(workspaces_lists) do
    local sc = tostring(i)
    local press_callback = function()
      workspaces.open(workspace.name)
      -- vim.schedule(function()
      --   sessions.load(const.session_base_path .. const.path_separator .. workspace.name)
      -- end)
    end
    local workspace_dir = workspace_tools.workspace_filename_to_dir(workspace.name)
    local button_text = workspace_dir == vim.loop.cwd() and workspace_dir .. ' (当前项目)' or workspace_dir
    table.insert(projects.val[4].val[1].val, {
      opts = {
        position = 'center',
        keymap = {
          'n',
          '<CR>',
          press_callback,
          { silent = true, noremap = true },
        },
        shortcut = '[' .. i .. '] ',
        cursor = 1,
        align_shortcut = 'center',
        shrink_margin = false,
        hl = 'Error',
        hl_shortcut = { { 'Operator', 0, 1 }, { 'Number', 1, #sc + 1 }, { 'Operator', #sc + 1, #sc + 2 } },
      },
      type = 'button',
      val = button_text,
    })
  end

  return {
    layout = {
      header,
      { type = 'padding', val = 1 },
      projects,
      { type = 'padding', val = 1 },
      footer,
      lazystats,
    },
    section = {
      header = header,
      projects = projects,
      footer = footer,
      lazystats = lazystats,
    },
    -- opts = {
    --   margin = 74,
    -- },
  }
end

local is_ok, alpha = pcall(require, 'alpha')
if not is_ok then
  return
end

local opts = get_opts()
alpha.setup(opts)

vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('TuoGroup', { clear = false }),
  pattern = 'LazyVimStarted',
  callback = function()
    local stats = require('lazy').stats()
    local footer_val =
      string.format('󱐋 %d/%d plugins loaded in %.3f ms', stats.loaded, stats.count, stats.startuptime)
    opts.section.footer.val = footer_val
    for _, s in ipairs { 'LazyStart', 'LazyDone', 'UIEnter' } do
      table.insert(opts.section.lazystats.val, {
        opts = {
          hl = 'Special',
          position = 'center',
        },
        type = 'text',
        val = string.format('%s %.3f ms', s, stats.times[s]),
      })
    end
    pcall(vim.cmd.AlphaRedraw)
  end,
})
