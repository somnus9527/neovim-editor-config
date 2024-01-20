local keymap = vim.keymap

local keymap_opt = {
  silent = true,
  noremap = true,
}
local extend = function(opts)
  local re_opt = {}
  if opts then
    re_opt = vim.tbl_deep_extend('force', keymap_opt, opts)
  end
  return re_opt
end

local keymaps = {
  { 'i', 'jk', '<Esc>', keymap_opt },
  { 'n', '<leader>e', '<cmd>Neotree toggle<cr>', extend { desc = '显示/隐藏NeoTree' } },
  { 'n', '<leader><leader>e', '<cmd>Neotree focus<cr>', extend { desc = '切换到NeoTree' } },
  -- { "n", "<leader>ec", "<cmd>Neotree close<cr>", keymap_opt },
  { 'i', '<M-j>', '<Down>', keymap_opt },
  { 'n', '<M-j>', 'ddp', keymap_opt },
  { 'i', '<M-k>', '<Up>', keymap_opt },
  { 'n', '<M-k>', 'dd2kp', keymap_opt },
  { 'i', '<M-h>', '<Left>', keymap_opt },
  { 'i', '<M-l>', '<Right>', keymap_opt },
  { 'n', '<M-d>', 'yyp', keymap_opt },
  { 'n', '<M-o>', 'o<Esc>', keymap_opt },
  { 'i', '<M-p>', '<C-r>+', keymap_opt },
  { 'i', '<M-0>', '<c-r>"', keymap_opt },
  { { 'n', 'v' }, '<M-p>', '"+p', keymap_opt },
  { { 'n', 'v' }, '<M-0>', '""p', keymap_opt },
  { { 'v', 'o', 'n' }, 'H', '^', keymap_opt },
  { { 'v', 'o', 'n' }, 'L', '$', keymap_opt },
  { 'n', '<M-v>', '<C-v>', keymap_opt },
  { 'n', '<M-b>', '<C-o>', keymap_opt },
  { 'n', '<M-\\>', '<cmd>split<cr>', keymap_opt },
  { 'n', '\\', '<cmd>vsplit<cr>', keymap_opt },
  -- { "n", "<M-]>", "<C-f>", keymap_opt },
  -- { "n", "<M-[>", "<C-u>", keymap_opt },
  { 'n', 'ss', '<cmd>HopChar1<cr>', extend { desc = '单个字符搜索' } },
  { 'n', 'sc', '<cmd>HopChar2<cr>', extend { desc = '两个字符搜索' } },
  { 'n', 'sw', '<cmd>HopWord<cr>', extend { desc = '单词搜索' } },
  { 'n', 'sp', '<cmd>HopPattern<cr>', extend { desc = '正则搜索' } },
  { 'n', 'sh', '<C-w>h', extend { desc = '切换到左侧窗口' } },
  { 'n', 'sl', '<C-w>l', extend { desc = '切换到右侧窗口' } },
  { 'n', 'sj', '<C-w>j', extend { desc = '切换到下方窗口' } },
  { 'n', 'sk', '<C-w>k', extend { desc = '切换到上方窗口' } },
  { 'n', '<M-.>', '<C-w>10>', extend { desc = '窗口宽度扩大' } },
  { 'n', '<M-,>', '<C-w>10<', extend { desc = '窗口宽度缩小' } },
  { 'n', ']]', '<cmd>BufferLineCycleNext<cr>', extend { desc = '切换下一个Tab签' } },
  { 'n', '[[', '<cmd>BufferLineCyclePrev<cr>', extend { desc = '切换上一个Tab签' } },
  { 'n', '=', '<cmd>BufferLinePick<cr>', extend { desc = '选择跳转指定Tab签' } },
  { 'n', '-', '<cmd>BufferLinePickClose<cr>', extend { desc = '选择关闭指定Tab签' } },
  { 'n', '<leader>g', '<cmd>GitBlameToggle<cr>', extend { desc = '显示/隐藏Git Blame' } },
  { 'n', '<leader>ww', '<cmd>lua require("spectre").toggle()<CR>', extend { desc = '显示/隐藏Spectre' } },
  {
    'n',
    '<leader>ws',
    '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
    extend { desc = '搜索当前单词(spectre)' },
  },
  {
    'n',
    '<leader>wS',
    '<cmd>lua require("spectre").open_visual()<CR>',
    extend { desc = '搜索当前单词(spectre)' },
  },
  {
    'n',
    '<leader>wb',
    '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
    extend { desc = '只在当前Buffer搜索' },
  },
  { 'n', '<leader>mm', '<Plug>(Marks-toggle)', { noremap = false, desc = '添加/删除标签' } },
  { 'n', '<leader>ma', '<Plug>(Marks-set)', { noremap = false, desc = '设置标签，需指定标签名' } },
  { 'n', '<leader>mp', '<Plug>(Marks-preview)', { noremap = false, desc = '预览标签位置文本' } },
  { 'n', '<leader>mx', '<Plug>(Marks-deleteline)', { noremap = false, desc = '删除本行标签'} },
  { 'n', '<leader>md', '<Plug>(Marks-deletebuf)', { noremap = false, desc = '删除文件标签' } },
  { 'n', '<leader>mb', '<cmd>MarksListBuf<CR>', extend { desc = '列出当前文件所有标签' } },
  { 'n', '<leader>ml', '<cmd>MarksListAll<CR>', extend { desc = '列出所有文件所有标签' } },
  { 'v', '<C-r>', '"hy:%s/<C-r>h//gc<left><left><left>', extend { desc = '替换当前选择的文本(逐个确认)' } }
}

for _, value in pairs(keymaps) do
  keymap.set(value[1], value[2], value[3], value[4])
end

