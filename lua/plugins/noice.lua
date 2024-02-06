return {
  'folke/noice.nvim',
  event = 'VimEnter',
  -- enabled = false,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
    'hrsh7th/nvim-cmp',
  },
  config = function()
    local opts = {
      -- lsp = {
      --   override = {
      --     ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      --     ['vim.lsp.util.stylize_markdown'] = true,
      --     ['cmp.entry.get_documentation'] = true,
      --   },
      -- },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = false,
        lsp_doc_border = false,
      },
    }
    local notify = require 'noice'
    notify.setup(opts)
  end,
}
