return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = 'Neotree',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    local icons = require 'tools.icons'
    local opt = {
      close_if_last_window = true,
      window = {
        mappings = {
          -- 移动窗口我用的s快捷键，避免冲突
          ['s'] = '',
          ['S'] = '',
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enable = true,
        },
        filtered_items = {
          visible = true,
        },
        -- 没有效果。。。
        use_libuv_file_watcher = true,
      },
      default_component_configs = {
        modified = {
          symbol = icons.git.modified,
          highlight = 'NeoTreeModified',
        },
        git_status = {
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            deleted = icons.git.removed,
            renamed = icons.git.renamed,
            untracked = icons.git.untracked,
            ignored = icons.git.ignored,
            unstaged = icons.git.unstaged,
            staged = icons.git.staged,
            conflict = icons.git.conflict,
          },
        },
      },
      buffers = {
        follow_current_file = {
          enable = true,
        },
      },
      event_handlers = {
        {
          event = 'neo_tree_window_after_open',
          handler = function()
            vim.schedule(function()
              vim.cmd 'Neotree dir=./'
            end)
          end,
        },
      },
    }
    require('neo-tree').setup(opt)
  end,
}
