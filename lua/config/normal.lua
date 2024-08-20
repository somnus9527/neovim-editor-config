local o = vim.o
local g = vim.g
local opt = vim.opt
local env = vim.env

g.mapleader = ' '
opt.shortmess = opt.shortmess + "c"
-- 显示行号
o.number = true
-- 相对行号原点显示原行号
-- 会造成gitsigns的图标覆盖行号,所以注释掉
-- o.signcolumn = 'number'
-- 显示相对行号
o.relativenumber = true
-- 开启终端使用GUI颜色
o.termguicolors = true
-- 设置行间距
o.linespace = 0
-- 高亮当前列
-- o.cursorcolumn = true
-- 高亮当前行
o.cursorline = true
-- 命令行使用的行数
o.cmdheight = 2
-- 行号使用的列数
o.numberwidth = 4
-- 缓冲区不使用交换文件
o.swapfile = false
-- tab转空格配置 start
-- 设置文件里Tab代表的空格数
o.tabstop = tonumber(env.indent)
-- (自动) 缩进每一步使用的空白数目
o.shiftwidth = tonumber(env.indent)
-- 编辑时tab代表的空格数
o.softtabstop = tonumber(env.indent)
-- 插入模式里: 插入 <Tab> 时使用合适数量的空格
o.expandtab = true
-- 自动缩进
o.autoindent = true
o.smartindent = true
