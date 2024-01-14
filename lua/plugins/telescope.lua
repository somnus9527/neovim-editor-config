-- 需要使用scoop安装ripgrep和make
return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzf-native.nvim',
  },
  config = function()
    local telescope = require 'telescope'
    local icons = require 'configs.icons'
    telescope.setup {
      defaults = {
        preview = {
          treesitter = false,
        },
        -- path_display = {
        --   'shorten',
        -- },
        prompt_prefix = icons.Other.Quickfixlogo .. ' ',
        selection_caret = icons.Other.Arrow .. ' ',
        mappings = {
          i = {
            ['<C-f>'] = function(...)
              return require('telescope.actions').preview_scrolling_down(...)
            end,
            ['<C-b>'] = function(...)
              return require('telescope.actions').preview_scrolling_up(...)
            end,
            ['<a-n>'] = function(...)
              return require('telescope.actions').move_selection_next(...)
            end,
            ['<a-m>'] = function(...)
              return require('telescope.actions').move_selection_previous(...)
            end,
            ['<cr>'] = function(...)
              return require('telescope.actions').select_default(...)
            end,
          },
          n = {
            ['q'] = function(...)
              return require('telescope.actions').close(...)
            end,
            ['<cr>'] = function(...)
              return require('telescope.actions').select_default(...)
            end,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    }

    telescope.load_extension 'fzf'
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>.', '<cmd>Telescope find_files shorten_path=true<CR>', {desc = '文件搜索'})
    vim.keymap.set('n', '<leader>/', '<cmd>Telescope live_grep<CR>', {desc = '字符搜索'})
    vim.keymap.set('n', '<leader>b', builtin.buffers, {desc = 'Buffer搜索'})
    vim.keymap.set('n', '<leader>`', builtin.colorscheme, {desc = '切换主题'})
    vim.keymap.set('n', '<leader><leader>/', function()
      builtin.current_buffer_fuzzy_find()
    end, {desc = '字符搜索（当前文件）'})
  end,
}
