local M = {}

-- 配置备用主题插件的静态选项，供手动切换 colorscheme 时保持统一外观。
function M.setup_optional()
	require("tokyonight").setup({
		style = "storm",
		light_style = "day",
		transparent = true,
		terminal_colors = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
	})
end

return M
