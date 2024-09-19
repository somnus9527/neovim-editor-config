-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 先删除部分默认的快捷键配置
local del = vim.keymap.del

del("i", "<A-j>")
del("i", "<A-k>")
del("n", "<leader>|")

-- 增加自定义快捷键配置
local map = LazyVim.safe_keymap_set

map("i", "jk", "<Esc>", { desc = "退出编辑模式" })
map("i", "<A-j>", "<Down>", { desc = "光标下移一行" })
map("i", "<A-k>", "<Up>", { desc = "光标上移一行" })
map("i", "<A-h>", "<Left>", { desc = "光标左移一格" })
map("i", "<A-l>", "<Right>", { desc = "光标右移一格" })
map("n", "U", "<C-r>", { desc = "Redo" })
map({ "v", "o", "n" }, "<S-h>", "^", { desc = "移动光标到行首" })
map({ "v", "o", "n" }, "<S-l>", "$", { desc = "移动光标到行尾" })
map("n", "gb", "<C-o>", { desc = "返回" })
map("v", "<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "替换当前选择的文本(逐个确认)" })
map("i", "<A-p>", "<C-r>+", { desc = "插入模式粘贴系统剪切板内容" })
map("i", "<A-0>", '<C-r>"', { desc = "插入模式粘贴默认register中内容" })
map({ "n", "v" }, "<C-p>", '"+p', { desc = "普通/visual模式粘贴系统剪切板内容"})
map({ "n", "v" }, "<C-0>", '""p', { desc = "普通/visual模式粘贴默认register中内容"})
map("v", "p", '"_dP', { desc = "避免visual模式下粘贴影响正常yank的register" })
map("v", "<C-c>", '"+y', { desc = "复制选中内容到系统剪切板" })
map("n", "<leader>\\", "<C-w>v", { desc = "Split Window Right", remap = true })
map("n", "<C-x>", "<C-w>q", { desc = "关闭Window" })
