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
        -- 设置透明度的，效果不好
        -- winblend = 90,
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
    local km = vim.keymap
    km.set('n', '<leader>.', '<cmd>Telescope find_files shorten_path=true<CR>', {desc = '文件搜索'})
    km.set('n', '<leader>/', '<cmd>Telescope live_grep<CR>', {desc = '字符搜索'})
    km.set('n', '<leader>b', builtin.buffers, {desc = 'Buffer搜索'})
    km.set('n', '<leader>`', builtin.colorscheme, {desc = '切换主题'})
    km.set('n', '<leader><leader>/', function()
      builtin.current_buffer_fuzzy_find()
    end, {desc = '字符搜索（当前文件）'})
    -- git 相关
    km.set('n', '<leader>gcc', '<cmd>Telescope git_bcommits<CR>', {desc = 'git commit历史, 当前buffer'})
    km.set('v', '<leader>gcv', '<cmd>Telescope git_bcommits_range<CR>', {desc = 'git commit历史, 当前选中的内容'})
    km.set('n', '<leader>gca', '<cmd>Telescope git_commits<CR>', {desc = 'git commit历史'})
    km.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', {desc = 'git status'})
    km.set('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', {desc = 'git branches'})
    -- 重新打开telescope，保留上次的搜索状态
    km.set('n', '<leader><leader>r', '<cmd>Telescope resume<CR>', {desc = '重打开Telescope'})
    km.set('n', '<leader>lr', '<cmd>Telescope lsp_references<CR>', {desc = 'lsp references'})
    km.set('n', '<leader>li', '<cmd>Telescope lsp_implementations<CR>', {desc = 'lsp implementations'})
    -- marks 使用marks插件管理
    -- km.set('n', '<leader>m', '<cmd>Telescope marks<CR>', {desc = 'marks'})
  end,
}
