-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here


-- 使用fzf-lua替换telescope, 取消使用fzf-lua，占用大量文件句柄
-- vim.g.lazyvim_picker = "fzf"
vim.g.lazyvim_picker = "telescope"
vim.g.autoformat = false
vim.g.bigfile_size = 1024 * 1024 * 5 -- 5 MB

local opt = vim.opt

-- 不使用系统粘贴板
opt.clipboard = ""
opt.cmdheight = 2
opt.numberwidth = 4
opt.showmode = true
opt.swapfile = false
