return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local trouble = require 'trouble'
    trouble.setup {}
    local utils = require 'utils'
    local keymaps = {
      {
        'n',
        '<leader>dd',
        function()
          trouble.toggle 'document_diagnostics'
        end,
        { desc = '显示/隐藏文件diagnostics' },
      },
      {
        'n',
        '<leader>dw',
        function()
          trouble.toggle 'workspace_diagnostics'
        end,
        { desc = '显示/隐藏工作目录所有diagnostics' },
      },
      {
        'n',
        '<leader>dq',
        function()
          trouble.toggle 'quick_fix'
        end,
        { desc = '显示/隐藏quick_fix' },
      },
    }
    utils.set_keymap(keymaps)
  end,
}
