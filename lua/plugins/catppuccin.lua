return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function ()
    local tools = require('tools.tools')
    local colorschemes = { 'catppuccin', 'catppuccin-latte', 'catppuccin-frappe', 'catppuccin-macchiato', 'catppuccin-mocha' }
    if tools.is_contain(vim.env.colorscheme, colorschemes) then
      vim.cmd("colorscheme " .. vim.env.colorscheme)
    end
  end
}
