return {
  'folke/todo-comments.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'ibhagwan/fzf-lua',
  },
  -- FIXME: qq
  -- TODO: qqq
  -- HACK: qqq
  -- WARNING: this
  -- PERFORMANCE: qqq
  -- INFO: ddddd
  -- TESTING: this
  config = function()
    local todo = require 'todo-comments'
    local icons = require 'tools.icons'
    local tools = require 'tools.tools'
    local opts = {
      keywords = {
        FIX = {
          icon = icons.todo.Fix .. ' ', -- icon used for the sign, and in search results
          color = 'error', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = icons.todo.Todo .. ' ', color = 'info', alt = { 'TODO' } },
        HACK = { icon = icons.todo.Hack .. ' ', color = 'warning', alt = { 'HACK' } },
        WARN = { icon = icons.todo.Warn .. ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = icons.todo.Perf .. ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = icons.todo.Note .. ' ', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = icons.todo.Test .. ' ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
    }
    todo.setup(opts)
    local keymaps = {
      -- { 'n', '<leader>tt', '<cmd>TodoTrouble<CR>', { desc = '在Trouble中展示所有TODO Comments' } },
      { 'n', '<leader>t', '<cmd>TodoFzfLua<CR>', { desc = '在FzfLua中展示所有TODO Comments' } },
      {
        'n',
        '<A-]>',
        function()
          todo.jump_next()
        end,
        { desc = '跳到下一个TODO Comments' },
      },
      {
        'n',
        '<A-[>',
        function()
          todo.jump_prev()
        end,
        { desc = '跳到上一个TODO Comments' },
      },
    }
    tools.set_keymap(keymaps)
  end,
}
