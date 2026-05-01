local M = {}

--[[
初始化 nvim-ts-autotag。
该插件负责 DOM 类文件中标签自动闭合和重命名，当前沿用默认配置。

返回值：本函数只初始化插件配置，不返回业务数据。
]]
function M.setup()
	require("nvim-ts-autotag").setup()
end

return M
