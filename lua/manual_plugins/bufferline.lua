return {
  'akinsho/bufferline.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('bufferline').setup {
      options = {
        numbers = 'ordinal',
        separator_style = "thick",
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = false,
      },
    }
  end,
}
