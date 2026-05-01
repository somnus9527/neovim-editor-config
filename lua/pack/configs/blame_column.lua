local M = {}

-- 配置 blame-column.nvim，保留日期格式、忽略列表和提交信息快捷键。
function M.setup()
	require("blame-column").setup({
		ignore_filetypes = {
			"toggleterm",
			"neo-tree",
		},
		datetime_format = "%Y.%m.%d",
		commit_info = {
			datetime_format = "%Y.%m.%d %H:%M:%S",
		},
		mappings = {
			open_commit_info_from_blame = "K",
			close_commit_info_from_blame = "q",
			close_commit_info = "q",
			open_full_commit_info_from_blame = "L",
		},
	})
end

return M
