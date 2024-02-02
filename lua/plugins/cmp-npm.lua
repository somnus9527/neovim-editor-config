return {
  'David-Kunz/cmp-npm',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = 'json',
  lazy = true,
  config = function()
    local cmp = require 'cmp-npm'
    cmp.setup {
      mapping = {
        ['<CR>'] = cmp.mapping {
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm { select = true },
          c = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
        },
      },
    }
  end,
}
