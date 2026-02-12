local g = vim.g
g.mapleader = " "
g.maplocalleader = ","
-- 取消lazyvim对配置中的plugins配置的顺序校验
g.lazyvim_check_order = false
-- emmet.nvim插件的配置
-- 只在插入模式启用 Emmet
g.user_emmet_mode = 'i'
-- 清空内置快捷键
g.user_emmet_leader_key = '<NOP>'
