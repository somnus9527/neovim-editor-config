-- 需要使用scoop安装ripgrep和make
return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzf-native.nvim',
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-file-browser.nvim',
  },
  config = function()
    local telescope = require 'telescope'
    local icons = require 'configs.icons'
    local utils = require 'utils'
    local fb_actions = require('telescope').extensions.file_browser.actions
    -- local telescopeConfig = require("telescope.config")
    --
    -- -- Clone the default Telescope configuration
    -- local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
    --
    -- -- I want to search in hidden/dot files.
    -- table.insert(vimgrep_arguments, "--hidden")
    -- -- I don't want to search in the `.git` directory.
    -- table.insert(vimgrep_arguments, "--glob")
    -- table.insert(vimgrep_arguments, "!**/.git/*")
    telescope.setup {
      defaults = {
        -- vimgrep_arguments = vimgrep_arguments,
        preview = {
          treesitter = false,
        },
        file_ignore_patterns = {
          'node_modules',
          'build',
          'dist',
          '.git',
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
            ['<cr>'] = function(...)
              return require('telescope.actions').select_default(...)
            end,
            -- 神奇。。。直接在这边设置，<CR>就不生效，见鬼了。。。
            -- 妈蛋，就 <C-n> <C-m>不行。。。
            ['<c-j>'] = function(...)
              return require('telescope.actions').preview_scrolling_down(...)
            end,
            ['<c-k>'] = function(...)
              return require('telescope.actions').preview_scrolling_up(...)
            end,
            ['<a-n>'] = function(...)
              return require('telescope.actions').move_selection_next(...)
            end,
            ['<a-m>'] = function(...)
              return require('telescope.actions').move_selection_previous(...)
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
      pickers = {
        find_files = {
          -- hidden = true,
          find_command = { 'rg', '--files', '--hidden', '-g', '!.git'},
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
        file_browser = {
          theme = 'ivy',
          hijack_netrw = true,
          mappings = {
            ['i'] = {},
            ['n'] = {
              ['a'] = fb_actions.create,
              ['r'] = fb_actions.rename,
              ['m'] = fb_actions.move,
              ['y'] = fb_actions.copy,
              ['d'] = fb_actions.remove,
              ['o'] = fb_actions.open,
              ['h'] = fb_actions.toggle_hidden,
              ['f'] = fb_actions.toggle_browser,
              ['t'] = fb_actions.change_cwd,
              ['g'] = fb_actions.goto_cwd,
              ['p'] = fb_actions.goto_parent_dir,
              ['e'] = fb_actions.goto_home_dir,
            },
          },
        },
      },
    }

    telescope.load_extension 'fzf'
    telescope.load_extension 'file_browser'
    local builtin = require 'telescope.builtin'
    local keymaps = {
      { 'n', '<leader><leader>', '<cmd>Telescope find_files shorten_path=true<CR>', { desc = '文件搜索' } },
      { 'n', '<leader>.', '<cmd>Telescope live_grep<CR>', { desc = '字符搜索' } },
      { 'n', "<leader>'", '<cmd>Telescope registers<CR>', { desc = '当前registers' } },
      { 'n', '<leader>o', '<cmd>Telescope oldfiles<CR>', { desc = '搜索之前打开过的文件' } },
      { 'n', '<leader>b', builtin.buffers, { desc = 'Buffer搜索' } },
      { 'n', '<leader>`', builtin.colorscheme, { desc = '主题切换' } },
      {
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find()
        end,
        { desc = '字符搜索（当前文件内）' },
      },
      { 'n', '<leader>gcc', '<cmd>Telescope git_bcommits<CR>', { desc = 'git commit历史，当前Buffer' } },
      {
        'v',
        '<leader>gcv',
        '<cmd>Telescope git_bcommits_range<CR>',
        { desc = 'git commit历史，当前选中的内容' },
      },
      { 'n', '<leader>gca', '<cmd>Telescope git_commits<CR>', { desc = 'git commit历史' } },
      { 'n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'git status' } },
      { 'n', '<leader>gb', '<cmd>Telescope git_branches<CR>', { desc = 'git branches' } },
      { 'n', '<leader>,', '<cmd>Telescope resume<CR>', { desc = '重打开Telescope' } },
      { 'n', '<leader>lr', '<cmd>Telescope lsp_references<CR>', { desc = 'lsp references' } },
      { 'n', '<leader>li', '<cmd>Telescope lsp_implementations<CR>', { desc = 'lsp implementations' } },
      { 'n', '<leader>ls', '<cmd>Telescope lsp_document_symbols<CR>', { desc = 'lsp document symbols' } },
      {
        'n',
        '<leader>ld',
        function()
          builtin.diagnostics { bufnr = 0 }
        end,
        { desc = 'lsp diagnostics' },
      },
    }
    utils.set_keymap(keymaps)
  end,
}
