local tools = require 'tools.tools'
function set_terminal_keymaps()
  local keymaps = {
    { 't', '<esc>', [[<C-\><C-n>]], { desc = '回到Normal模式' } },
    { 't', 'jk', [[<C-\><C-n>]], { desc = '回到Normal模式' } },
    { 't', '<C-h>', [[<C-\><C-n><C-W>h]], { desc = '聚焦到左边终端窗口' } },
    { 't', '<C-j>', [[<C-\><C-n><C-W>j]], { desc = '聚焦到下边终端窗口' } },
    { 't', '<C-k>', [[<C-\><C-n><C-W>k]], { desc = '聚焦到上边终端窗口' } },
    { 't', '<C-l>', [[<C-\><C-n><C-W>l]], { desc = '聚焦到右边终端窗口' } },
  }
  tools.set_buf_keymap(keymaps)
end

-- 自动注册快捷键
vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'

local terminal = require('toggleterm.terminal').Terminal
local lazygit = terminal:new {
  cmd = 'lazygit',
  hidden = true,
}
local node = terminal:new {
  cmd = 'node',
  hidden = true,
}
function _Lazygit_Toggle()
  lazygit:toggle()
end

function _Node_Toggle()
  node:toggle()
end

local api = vim.api
-- api.nvim_create_augroup('Somnus_Terminal', {})
api.nvim_create_user_command('ToggleLazygit', function()
  _Lazygit_Toggle()
end, {})
api.nvim_create_user_command('ToggleNode', function()
  _Node_Toggle()
end, {})
local keymaps = {
  -- { 'n', '<leader>tl', '<cmd>lua _Lazygit_Toggle()<CR>', { desc = '打开/关闭Lazygit Terminal' } },
  -- { 'n', '<leader>tn', '<cmd>lua _Node_Toggle()<CR>', { desc = '打开/关闭Node Terminal' } },
  { 'n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', { desc = '打开Terminal Float模式' } },
  { 'n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<CR>', { desc = '打开Terminal Vertical模式' } },
  { 'n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<CR>', { desc = '打开Terminal Horizontal模式' } },
}
tools.set_keymap(keymaps)
