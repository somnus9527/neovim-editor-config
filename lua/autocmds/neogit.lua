local group = vim.api.nvim_create_augroup('SomnusNeogit', { clear = true })
vim.api.nvim_create_autocmd('User', {
  pattern = 'NeogitPushComplete',
  group = group,
  -- callback = require('neogit').close,
  callback = function()
      vim.cmd('q')
  end
})
