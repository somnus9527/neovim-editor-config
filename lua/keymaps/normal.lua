local const = require "tools.const"
local tools = require "tools.tools"
local trigger = require 'tools.trigger'

local keymaps = {
  { { 'i', 'n', 'v' }, '<Esc>', ':lua custom_esc_behavior()<CR>', const.default_keymap_opt },
  { 'i', 'jk', '<Esc>', const.default_keymap_opt, { desc = '推出编辑模式' } },
  { 'n', '<leader>e', '<cmd>Oil<CR>', const.default_keymap_opt, { desc = '打开文件树系统' } },
  { 'n', '<leader>c', ':lua require("neogen").generate()<CR>', const.default_keymap_opt, { desc = '添加注释' } },
  { 'n', 'sh', '<C-w>h', { desc = '切换到左侧窗口' } },
  { 'n', 'sl', '<C-w>l', { desc = '切换到右侧窗口' } },
  { 'n', 'sj', '<C-w>j', { desc = '切换到下方窗口' } },
  { 'n', 'sk', '<C-w>k', { desc = '切换到上方窗口' } },
  { 'n', 'U', '<C-r>', { desc = 'Redo' } },
  { 'i', '<M-j>', '<Down>', const.default_keymap_opt },
  { 'n', '<M-j>', 'ddp', const.default_keymap_opt },
  { 'i', '<M-k>', '<Up>', const.default_keymap_opt },
  { 'n', '<M-k>', 'dd2kp', const.default_keymap_opt },
  { 'i', '<M-h>', '<Left>', const.default_keymap_opt },
  { 'i', '<M-l>', '<Right>', const.default_keymap_opt },
  { 'n', '<M-d>', 'yyp', const.default_keymap_opt },
  { 'n', '<M-o>', 'o<Esc>', const.default_keymap_opt },
  { 'i', '<M-p>', '<C-r>+', const.default_keymap_opt },
  { 'i', '<M-0>', '<c-r>"', const.default_keymap_opt },
  { { 'n', 'v' }, '<M-p>', '"+p', const.default_keymap_opt },
  { { 'n', 'v' }, '<M-0>', '""p', const.default_keymap_opt },
  { { 'v', 'o', 'n' }, 'H', '^', const.default_keymap_opt },
  { { 'v', 'o', 'n' }, 'L', '$', const.default_keymap_opt },
  { 'n', '<M-v>', '<C-v>', const.default_keymap_opt },
  { 'n', 'gb', '<C-o>', const.default_keymap_opt },
  { 'n', '<M-\\>', '<cmd>FocusSplitDown<cr>', const.default_keymap_opt },
  { 'n', '\\', '<cmd>FocusSplitRight<cr>', const.default_keymap_opt },
  { 'n', '<M-=>', '<C-w>10>', { desc = '窗口宽度扩大' } },
  { 'n', '<M-->', '<C-w>10<', { desc = '窗口宽度缩小' } },
  { 'v', '<', '<gv', { desc = '避免visual模式下处理缩进之后，选区丢失' } },
  { 'v', '>', '>gv', { desc = '避免visual模式下处理缩进之后，选区丢失' } },
  { 'v', 'p', '"_dP', { desc = '避免visual模式下粘贴影响正常yank的register' } },
  { 'v', '<C-r>', '"hy:%s/<C-r>h//gc<left><left><left>', { desc = '替换当前选择的文本(逐个确认)' } },
  { 'v', '<C-c>', '"+y', { desc = '复制选中内容到系统粘贴板' } },
  { { 'n', 'v' }, '<leader>-', tools.delete_other_unmodified_buffers, { desc = '删除其它buffer' } },
  -- Plugin: hop快捷键
  { 'n', 'ss', '<cmd>HopChar1<cr>', { desc = '单个字符搜索' } },
  { 'n', 'sc', '<cmd>HopChar2<cr>', { desc = '两个字符搜索' } },
  { 'n', 'sw', '<cmd>HopWord<cr>', { desc = '单词搜索' } },
  { 'n', 'sp', '<cmd>HopPattern<cr>', { desc = '正则搜索' } },
  -- Plugin: bufferline快捷键
  { 'n', ']]', '<cmd>BufferLineCycleNext<cr>', { desc = '切换下一个Tab签' } },
  { 'n', '[[', '<cmd>BufferLineCyclePrev<cr>', { desc = '切换上一个Tab签' } },
  { 'n', '=', '<cmd>BufferLinePick<cr>', { desc = '选择跳转指定Tab签' } },
  { 'n', '-', '<cmd>BufferLinePickClose<cr>', { desc = '选择关闭指定Tab签' } },
  -- Plugin: spectre快捷键
  {
    'n',
    '<leader>ww',
    function()
      trigger.trigger_user_cmd 'SpectreToggle'
    end,
    { desc = '显示/隐藏Spectre' },
  },
  {
    'n',
    '<leader>ws',
    '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
    { desc = '搜索当前单词(spectre)' },
  },
  {
    'n',
    '<leader>wS',
    '<cmd>lua require("spectre").open_visual()<CR>',
    { desc = '搜索当前单词(spectre)' },
  },
  {
    'n',
    '<leader>wb',
    '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
    { desc = '只在当前Buffer搜索' },
  },
}

tools.set_keymap(keymaps)
