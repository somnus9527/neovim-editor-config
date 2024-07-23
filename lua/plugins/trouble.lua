return {
  'folke/trouble.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local trouble = require 'trouble'
    trouble.setup({
      auto_close = true,
      focus = true,
      keys = {
        ['<cr>'] = "jump_close",
        o = "jump",
      }
    })
    local tools = require 'tools.tools'
    local keymaps = {
      {
        'n',
        '<leader>da',
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        { desc = '显示/隐藏文件diagnostics' },
      },
      {
        'n',
        '<leader>dw',
        "<cmd>Trouble diagnostics toggle<cr>",
        { desc = '显示/隐藏工作目录所有diagnostics' },
      },
      {
        'n',
        '<leader>df',
        function()
          trouble.toggle 'quick_fix'
        end,
        { desc = '显示/隐藏quick_fix' },
      },
    }
    tools.set_keymap(keymaps)
  end,
}
