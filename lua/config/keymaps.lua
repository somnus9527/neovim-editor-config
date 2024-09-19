-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- 先删除部分默认的快捷键配置
local del = vim.keymap.del

del("i", "<A-j>")
del("i", "<A-k>")

local map = LazyVim.safe_keymap_set

map("i", "jk", "<Esc>", { desc = "退出编辑模式" })
map("i", "<A-j>", "<Down>", { desc = "光标下移一行" })
map("i", "<A-k>", "<Up>", { desc = "光标上移一行" })
map("i", "<A-h>", "<Left>", { desc = "光标左移一格" })
map("i", "<A-l>", "<Right>", { desc = "光标右移一格" })
