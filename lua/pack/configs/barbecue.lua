local M = {}

-- 配置 barbecue 面包屑，禁用自动 navic attach 并排除 UI buffer。
function M.setup()
	require("barbecue").setup({
		attach_navic = false,
		exclude_filetypes = {
			"neo-tree",
			"toggleterm",
			"qf",
			"trouble",
		},
	})
end

return M
