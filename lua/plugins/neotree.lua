return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = 'Neotree',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    { 's1n7ax/nvim-window-picker', version = '2.*' },
  },
  config = function()
    local icons = require 'tools.icons'
    local tools = require 'tools.tools'
    -- 配置diagnostics图标
    for name, icon in pairs(icons.diagnostics) do
      local name = 'DiagnosticSign' .. name
      vim.fn.sign_define(name, { texthl = name, text = icon, numhl = '' })
    end
    local opt = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      source_selector = {
        winbar = true,
        statusline = false,
        content_layout = 'center',
        tabs_layout = 'equal',
        show_separator_on_edge = true,
        sources = { -- table
          {
            source = 'filesystem', -- string
            display_name = ' 󰉓 Files ', -- string | nil
          },
          {
            source = 'buffers', -- string
            display_name = ' 󰈚 Buffers ', -- string | nil
          },
          {
            source = 'git_status', -- string
            display_name = ' 󰊢 Git ', -- string | nil
          },
        },
      },
      sources = {
        'filesystem',
        'buffers',
        'git_status',
      },
      window = {
        width = 60,
        mappings = {
          -- 移动窗口我用的s快捷键，避免冲突
          ['s'] = '',
          ['S'] = '',
          ['z'] = '',
          ['m'] = {
            'move',
            config = {
              show_path = 'relative',
            },
          },
          ['<left>'] = 'prev_source',
          ['<right>'] = 'next_source',
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          visible = true,
        },
        -- 没有效果。。。
        use_libuv_file_watcher = true,
        commands = {
          -- Override delete to use trash instead of rm
          delete = function(state)
            local path = state.tree:get_node().path
            tools.trash_file(path)
            -- vim.fn.system('trash ' .. vim.fn.fnameescape(path))
            require('neo-tree.sources.manager').refresh(state.name)
          end,
        },
      },
      default_component_configs = {
        use_git_status_colors = true,
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
          enabled = true,
        },
        bind_to_cwd = false,
      },
      event_handlers = {
        {
          event = 'neo_tree_window_after_open',
          handler = function()
            if _G.need_refresh_neotree then
              vim.schedule(function()
                vim.cmd 'Neotree dir=./'
                _G.need_refresh_neotree = false
              end)
            end
          end,
        },
      },
      git_status = {
        follow_current_file = true, -- This will automatically focus the current file in git_status tab
      },
    }
    require('neo-tree').setup(opt)
  end,
}
