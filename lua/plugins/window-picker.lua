return {
  's1n7ax/nvim-window-picker',
  cmd = 'SomnusWinPicker',
  version = '2.*',
  config = function()
    local picker = require 'window-picker'
    local opts = {
      hint = 'floating-big-letter',
      selection_chars = '1234567890',
      filter_rules = {
        autoselect_one = true,
        include_current_win = false,
        bo = {
          filetype = { 'neo-tree', 'alpha', 'notify' },
          buftype = { 'terminal', 'quickfix', 'noice' },
        },
      },
    }
    picker.setup(opts)
    require 'autocmds.window_picker'
  end,
}
