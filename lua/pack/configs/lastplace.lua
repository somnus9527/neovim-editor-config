local M = {}

-- 配置 lastplace.nvim，恢复文件历史光标位置并过滤特殊 buffer。
function M.setup()
	require("lastplace").setup({
		ignore_filetypes = {
			"gitcommit",
			"gitrebase",
			"svn",
			"hgcommit",
			"xxd",
			"COMMIT_EDITMSG",
		},
		ignore_buftypes = {
			"quickfix",
			"nofile",
			"help",
			"terminal",
		},
		center_on_jump = true,
		jump_only_if_not_visible = false,
		min_lines = 10,
		max_line = 0,
		open_folds = true,
		debug = false,
	})
end

return M
