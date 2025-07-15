local tools = require("tools.tools")

local keymaps = {
  { { 'i', 'n', 'v' }, '<Esc>', ':lua custom_esc_behavior()<CR>', { desc = '存在高亮先取消高亮' } },
  { 'i', 'jk', '<Esc>', { desc = '退出编辑模式' } },
  { 'n', '<leader>e', '<CMD>Oil<CR>', { desc = '打开Oil' } },
  { 'n', 'U', '<C-r>', { desc = 'Redo' } },
  { { 'v', 'o', 'n' }, '<S-h>', '^', { desc = '移动光标到行首' } },
  { { 'v', 'o', 'n' }, '<S-l>', '$', { desc = '移动光标到行尾' } },
  { 'i', '<A-h>', '<Left>', { desc = '光标左移一位' } },
  { 'i', '<A-l>', '<Right>', { desc = '光标右移一位' } },
  { 'i', '<A-j>', '<Down>', { desc = '光标下移一位' } },
  { 'i', '<A-k>', '<Left>', { desc = '光标上移一位' } },
}

tools.set_keymap(keymaps)
