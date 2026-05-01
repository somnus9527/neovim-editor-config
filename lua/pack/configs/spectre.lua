local M = {}

-- 配置 Spectre 搜索替换界面，保留当前行替换和全局替换快捷键。
function M.setup()
	require("spectre").setup({
		is_block_ui_break = true,
		mapping = {
			["toggle_line"] = {
				map = "<A-y>",
				cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
				desc = "在当前行应用/取消替换",
			},
			["enter_file"] = {
				map = "<cr>",
				cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
				desc = "打开文件",
			},
			["run_current_replace"] = {
				map = "<C-y>",
				cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
				desc = "替换当前行",
			},
			["run_replace"] = {
				map = "<leader>y",
				cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
				desc = "全部替换",
			},
		},
	})
end

return M
