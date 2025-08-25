-- scoop install ripgrep
-- 安装sed,地址：https://gnuwin32.sourceforge.net/packages/sed.html
return {
  'nvim-pack/nvim-spectre',
  event = "VeryLazy",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('spectre').setup {
      is_block_ui_break = true,
      mapping = {
        ['toggle_line'] = {
          map = '<A-y>',
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = '在当前行应用/取消替换',
        },
        ['enter_file'] = {
          map = '<cr>',
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = '打开文件',
        },
        ['run_replace'] = {
          map = '<C-y>',
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = '全部替换',
        },
      },
    }
  end,
}
