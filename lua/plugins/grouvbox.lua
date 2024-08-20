return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  config = function ()
    if vim.env.colorscheme == 'gruvbox' then
      vim.cmd([[colorscheme gruvbox]])
    end
  end
}
