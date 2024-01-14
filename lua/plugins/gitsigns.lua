return {
  'lewis6991/gitsigns.nvim',
  config = function()
    local icons = require 'configs.icons'
    require('gitsigns').setup {
      signs = {
        add = { text = icons.git.added },
        change = { text = icons.git.modified },
        delete = { text = icons.git.removed },
        topdelete = { text = icons.git.topdelete },
        changedelete = { text = icons.git.changedelete },
        untracked = { text = icons.git.untracked },
      },
      -- gitsigns的git blame无法一次性展示整个buffer的，所以使用git-blame插件处理这个功能
      -- current_line_blame_opts = {
      --   virt_text_pos = ''
      -- },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        map('n', '<leader>hp', gs.preview_hunk, { desc = '预览git hunk' })
        map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>', { desc = '显示git diff' })
        -- map('n', '<leader>hs', '<cmd>Gitsigns stage_buffer<CR>')
        -- map('n', '<leader>hr', '<cmd>Gitsigns reset_buffer<CR>')
      end,
    }
  end,
}
