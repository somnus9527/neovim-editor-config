return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  event = { 'BufNewFile', 'BufReadPre' },
  config = function ()
    local context = require 'treesitter-context'
    local opts = {
      enable = true,
    }
    context.setup(opts)
  end
}
