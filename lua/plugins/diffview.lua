return {
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewFileHistory",
		},
		keys = {
			{ "<A-`>", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
			{ "<A-q>", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
			{ "<A-e>", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview Files Toggle" },
			{ "<A-h>", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Files History" },
		},
		config = function()
			local cb = require("diffview.config").diffview_callback
			local actions = require("diffview.actions")

			require("diffview").setup({
				enhanced_diff_hl = true, -- 高亮增强
				view = {
					merge_tool = {
						layout = "diff3_vertical", -- 处理冲突时的布局: diff3_mixed / diff3_vertical
						disable_diagnostics = false, -- merge 时禁用诊断
					},
				},
				keymaps = {
					view = {
						["<tab>"] = cb("select_next_entry"), -- 切换下一个文件
						["<s-tab>"] = cb("select_prev_entry"), -- 切换上一个文件
						["gf"] = cb("goto_file"), -- 打开文件
						["<leader>e"] = cb("toggle_files"), -- 切换文件树
						{
							"n",
							"<A-'>",
							actions.prev_conflict,
							{ desc = "In the merge-tool: jump to the previous conflict" },
						},
						{
							"n",
							"<A-;>",
							actions.next_conflict,
							{ desc = "In the merge-tool: jump to the next conflict" },
						},
						{
							"n",
							"<A-o>",
							actions.conflict_choose("ours"),
							{ desc = "Choose the OURS version of a conflict" },
						},
						{
							"n",
							"<A-t>",
							actions.conflict_choose("theirs"),
							{ desc = "Choose the THEIRS version of a conflict" },
						},
						{
							"n",
							"<A-a>",
							actions.conflict_choose("all"),
							{ desc = "Choose all the versions of a conflict" },
						},
						{
							"n",
							"dx",
							actions.conflict_choose("none"),
							{ desc = "Delete the conflict region" },
						},
						{
							"n",
							"<A-O>",
							actions.conflict_choose_all("ours"),
							{ desc = "Choose the OURS version of a conflict for the whole file" },
						},
						{
							"n",
							"<A-T>",
							actions.conflict_choose_all("theirs"),
							{ desc = "Choose the THEIRS version of a conflict for the whole file" },
						},
						{
							"n",
							"<A-A>",
							actions.conflict_choose_all("all"),
							{ desc = "Choose all the versions of a conflict for the whole file" },
						},
					},
					file_panel = {
						["j"] = cb("next_entry"),
						["k"] = cb("prev_entry"),
						["<cr>"] = cb("select_entry"),
						["o"] = cb("select_entry"),
						["R"] = cb("refresh_files"),
						["<tab>"] = cb("select_next_entry"),
						["<s-tab>"] = cb("select_prev_entry"),
					},
				},
			})
		end,
	},
}
