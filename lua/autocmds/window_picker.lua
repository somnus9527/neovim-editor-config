function WindowPicker()
  local is_ok, picker = pcall(require, 'window-picker')
  if not is_ok then
    return
  end
  picker.pick_window()
end
vim.api.nvim_create_user_command('SomnusWinPicker', WindowPicker, {})

