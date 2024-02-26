return {
  'folke/tokyonight.nvim',
  config = function()
    require('tokyonight').setup {
      styles = {
        keywords = {
          bold = true
        }
      },
    }
    vim.cmd [[colorscheme tokyonight-night]]
  end,
}
