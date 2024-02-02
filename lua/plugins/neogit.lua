return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local neogit = require 'neogit'
    local utils = require 'utils'
    local opts = {
      mappings = {
        commit_editor = {
          ['q'] = 'Close',
          ['<C-c>'] = 'Submit',
          ['<C-q>'] = 'Abort',
        },
        rebase_editor = {
          ['p'] = 'Pick',
          ['r'] = 'Reword',
          ['e'] = 'Edit',
          ['s'] = 'Squash',
          ['f'] = 'Fixup',
          ['x'] = 'Execute',
          ['d'] = 'Drop',
          ['b'] = 'Break',
          ['q'] = 'Close',
          ['<cr>'] = 'OpenCommit',
          ['gk'] = 'MoveUp',
          ['gj'] = 'MoveDown',
          ['<C-c>'] = 'Submit',
          ['<C-q>'] = 'Abort',
        },
        finder = {
          ['<cr>'] = 'Select',
          ['<c-c>'] = 'Close',
          ['<esc>'] = 'Close',
          ['<c-n>'] = 'Next',
          ['<c-p>'] = 'Previous',
          ['<down>'] = 'Next',
          ['<up>'] = 'Previous',
          ['<tab>'] = 'MultiselectToggleNext',
          ['<s-tab>'] = 'MultiselectTogglePrevious',
          ['<c-j>'] = 'NOP',
        },
        popup = {
          ['?'] = 'HelpPopup',
          ['A'] = 'CherryPickPopup',
          ['D'] = 'DiffPopup',
          ['M'] = 'RemotePopup',
          ['P'] = 'PushPopup',
          ['X'] = 'ResetPopup',
          ['Z'] = 'StashPopup',
          ['b'] = 'BranchPopup',
          ['c'] = 'CommitPopup',
          ['f'] = 'FetchPopup',
          ['l'] = 'LogPopup',
          ['m'] = 'MergePopup',
          ['p'] = 'PullPopup',
          ['r'] = 'RebasePopup',
          ['v'] = 'RevertPopup',
        },
        status = {
          ['q'] = 'Close',
          ['I'] = 'InitRepo',
          ['1'] = 'Depth1',
          ['2'] = 'Depth2',
          ['3'] = 'Depth3',
          ['4'] = 'Depth4',
          ['<tab>'] = 'Toggle',
          ['x'] = 'Discard',
          ['s'] = 'Stage',
          ['S'] = 'StageUnstaged',
          ['<M-s>'] = 'StageAll',
          ['u'] = 'Unstage',
          ['U'] = 'UnstageStaged',
          ['$'] = 'CommandHistory',
          ['#'] = 'Console',
          ['Y'] = 'YankSelected',
          ['<c-r>'] = 'RefreshBuffer',
          ['<enter>'] = 'GoToFile',
          ['<c-v>'] = 'VSplitOpen',
          ['<c-x>'] = 'SplitOpen',
          ['<c-t>'] = 'TabOpen',
          ['{'] = 'GoToPreviousHunkHeader',
          ['}'] = 'GoToNextHunkHeader',
        },
      },
    }
    neogit.setup(opts)
    local keymaps = {
      { 'n', '<leader>gg', '<cmd>Neogit cwd=%:p:h<CR>', { desc = '打开Neogit' } },
      {
        'n',
        '<leader>gq',
        function()
          neogit.close()
        end,
        { desc = '关闭Neogit' },
      },
    }
    utils.set_keymap(keymaps)
    require 'autocmds.neogit'
  end,
}
