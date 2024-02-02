-- windows下的内置终端很难用，再加上lazygit简直是屎上加屎
-- 发现是中文的问题，我需要提供lazygit配置，所以重新使用lazygit.nvim
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  -- cmd = 'ToggleTerm',
  event = 'BufEnter',
  config = function()
    local term = require 'toggleterm'
    local opt = {
      size = function(term)
        if term.direction == 'horizontal' then
          return 20
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    }
    term.setup(opt)
    require 'autocmds.term'
  end,
}
