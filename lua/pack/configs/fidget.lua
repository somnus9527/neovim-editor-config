local M = {}

-- 配置 fidget 的 LSP 进度展示和通知过滤，减少已完成任务噪音。
function M.setup()
	require("fidget").setup({
		progress = {
			ignore_done_already = true,
			ignore_empty_message = true,
			display = {
				render_limit = 3,
			},
		},
		notification = {
			filter = vim.log.levels.ERROR,
		},
	})
end

return M
