return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    local icons = require 'configs.icons'
    local opt = {
      close_if_last_window = true,
      window = {
        mappings = {
          ['s'] = '',
          ['S'] = '',
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enable = true
        },
        filtered_items = {
          visible = true,
        },
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
    }
    require('neo-tree').setup(opt)
  end,
}
