local tools = require 'tools.tools'
local aug = vim.api.nvim_create_augroup('somnus_colorscheme', {
  clear = true,
})

vim.api.nvim_create_autocmd('User',{
  pattern = "LazyDone",
  group = aug,
  callback = function()
    local conf = tools.load_conf()
    vim.o.background = "dark"
    vim.cmd('colorscheme ' .. conf.default.colorscheme)
  end
})
