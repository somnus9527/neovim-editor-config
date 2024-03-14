return {
  'echasnovski/mini.surround',
  event = { 'BufNewFile', 'BufReadPre' },
  opts = {
    mappings = {
      add = 'sa',
      delete = 'sd',
      -- find = 'gsf',
      -- highlight = 'gsh',
      -- replace = 'cs',
      update_n_lines = 'gsn',
      find = 'sf', -- Find surrounding (to the right)
      find_left = 'sF', -- Find surrounding (to the left)
      highlight = 'sv', -- Highlight surrounding
      replace = 'sr', -- Replace surrounding
    },
  },
}
