local M = {}

-- 初始化 render-markdown.nvim，当前保持空配置以沿用插件默认渲染行为。
function M.setup()
	require("render-markdown").setup({})
end

return M
