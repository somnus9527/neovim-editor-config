return {
	"folke/trouble.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			symbols = {
				win = {
					size = 100,
					position = "right",
				},
			},
		},
		keys = {
			o = nil,
			["<cr>"] = "jump_close",
		},
	},
	keys = {
		{
			"<leader>xx",
			function()
				vim.cmd("Trouble diagnostics toggle filter.buf=0")
				-- 延迟执行，确保窗口创建完成
				vim.defer_fn(function()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].filetype == "trouble" then
							vim.api.nvim_set_current_win(win)
							break
						end
					end
				end, 50) -- 50ms 延迟，一般足够
			end,
			desc = "当前Buffer的Diagnostics",
		},
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>", desc = "当前Workspace的Diagnostics" },
	},
}
