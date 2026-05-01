local M = {}

-- 配置颜色预览，覆盖 CSS 函数、Sass parser 和 Tailwind LSP 颜色来源。
function M.setup()
	require("colorizer").setup({
		lazy_load = true,
		user_default_options = {
			names = false,
			rgb_fn = true,
			hsl_fn = true,
			css = true,
			tailwind = "lsp",
			sass = {
				enable = true,
				parsers = {
					"css",
				},
			},
		},
	})
end

return M
