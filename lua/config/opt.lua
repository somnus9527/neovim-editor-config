local opt = vim.opt

-- 开启终端truecolor, 否则主题色会失效
opt.termguicolors = true
-- 控制neovim消息的简洁程度
-- 关闭插入模式补全菜单中的 “match 1 of 5” 提示，避免干扰补全菜单
opt.shortmess = opt.shortmess + "c"
-- 显示行号
opt.number = true
-- 显示相对行号
opt.relativenumber = true
-- 行间距
opt.linespace = 2
-- 高亮当前行
opt.cursorline = true
-- 高亮当前列
opt.cursorcolumn = true
-- 行号占用的列数
opt.numberwidth = 6
-- 命令行占用的行数
opt.cmdheight = 1
-- 针对neovim的一些临时文件的配置 start
-- 缓冲区不使用交换文件
opt.swapfile = false
-- 禁用 backup 文件
opt.backup = false
opt.writebackup = false
-- 启用 undo 文件，设置保存目录
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
-- end
-- 针对缩进，自动缩进的所有配置 start
-- 设置文件里Tab代表的空格数 2
opt.tabstop = 2
-- (自动) 缩进每一步使用的空白数目
opt.shiftwidth = 2
-- 编辑时tab代表的空格数
opt.softtabstop = 2
-- 插入模式里: 插入 <Tab> 时使用合适数量的空格
opt.expandtab = true
-- 自动缩进
opt.autoindent = true
opt.smartindent = true
-- end
