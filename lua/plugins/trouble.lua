return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('trouble').setup {}
    local km = vim.keymap

    km.set('n', '<leader>dd', function()
      require('trouble').toggle 'document_diagnostics'
    end, { desc = '显示/隐藏文件diagnostics' })
    km.set('n', '<leader>dw', function()
      require('trouble').toggle 'workspace_diagnostics'
    end, { desc = '显示/隐藏工作目录所有diagnostics' })
    km.set('n', '<leader>dq', function()
      require('trouble').toggle 'quick_fix'
    end, { desc = '显示/隐藏quick_fix' })
  end,
}
