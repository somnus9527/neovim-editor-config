return {
  'echasnovski/mini.nvim',
  config = function()
    local miniclue = require 'mini.clue'
    miniclue.setup {
      triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        -- marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },
        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
        -- Window commands
        { mode = 'n', keys = '<C-w>' },
        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
        -- `m` key
        { mode = 'n', keys = 's' }
      },
      clues = {
        -- 内置的keymap
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      },
      -- window = {
      --   delay = 500,
      -- },
    }
  end,
}
