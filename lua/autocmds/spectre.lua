function spectreToggleHandler()
  local ok, spectre = pcall(require, 'spectre')
  if not ok then
    return
  end
  spectre.toggle()
end

vim.api.nvim_command('autocmd User SpectreToggle lua spectreToggleHandler()')
