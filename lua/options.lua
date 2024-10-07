require "nvchad.options"

-- add yours here!

local o = vim.o
local opt = vim.opt

o.number = true
o.relativenumber = true
o.termguicolors = true
o.linespace = 0
o.cursorline = true
o.cmdheight = 2
o.swapfile = false
o.shadafile = "NONE"
o.backup = false
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.autoindent = true
o.smartindent = true
o.numberwidth = 4
-- 使用 Treesitter 的折叠表达式
o.foldmethod = 'expr'
o.foldexpr = 'nvim_treesitter#foldexpr()'
-- 自动打开文件时不折叠
o.foldlevelstart = 99

opt.shortmess = opt.shortmess + "c"
-- 不使用系统粘贴板
opt.clipboard = ""
