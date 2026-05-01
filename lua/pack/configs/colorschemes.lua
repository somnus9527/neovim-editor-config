local M = {}

-- 配置备用主题插件的静态选项，供手动切换 colorscheme 时保持历史外观。
function M.setup_optional()
	require("tokyonight").setup({
		style = "moon",
	})
end

return M
