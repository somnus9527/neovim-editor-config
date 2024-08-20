return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function ()
    if vim.env.colorscheme == 'gruvbox' then
      vim.cmd([[colorscheme tokyonight]])
    end
  end
}
