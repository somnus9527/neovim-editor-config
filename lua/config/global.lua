local g = vim.g

--[[
设置全局 leader 键，后续 keymap 模块会依赖这两个前置值。
]]
g.mapleader = " "
g.maplocalleader = ","

--[[
配置 Emmet 只在插入模式启用，避免普通模式触发插件默认映射。
]]
g.user_emmet_mode = 'i'

--[[
清空 Emmet 内置 leader，由自有键位配置统一接管。
]]
g.user_emmet_leader_key = '<NOP>'
