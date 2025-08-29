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

			require("diffview").setup({
				enhanced_diff_hl = true, -- 高亮增强
				view = {
					merge_tool = {
						layout = "diff3_mixed", -- 处理冲突时的布局: diff3_mixed / diff3_vertical
						disable_diagnostics = false, -- merge 时禁用诊断
					},
				},
				keymaps = {
					view = {
						["<tab>"] = cb("select_next_entry"), -- 切换下一个文件
						["<s-tab>"] = cb("select_prev_entry"), -- 切换上一个文件
						["gf"] = cb("goto_file"), -- 打开文件
						["<leader>e"] = cb("toggle_files"), -- 切换文件树
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
	{
		"akinsho/git-conflict.nvim",
		lazy = true, -- 不要全局加载
		config = function()
			require("git-conflict").setup()
		end,
		init = function()
			-- 当进入 Diffview buffer 时，再懒加载并设置 buffer-local keymap
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "DiffviewFiles", "DiffviewFileHistory" },
				callback = function()
					-- 确保加载插件
					require("lazy").load({ plugins = { "git-conflict.nvim" } })

					-- keymaps
					local opts = { silent = true }
					vim.keymap.set(
						"n",
						"<A-o>",
						"<Plug>(git-conflict-ours)",
						vim.tbl_extend("force", opts, { desc = "Choose Ours" })
					)
					vim.keymap.set(
						"n",
						"<A-t>",
						"<Plug>(git-conflict-theirs)",
						vim.tbl_extend("force", opts, { desc = "Choose Theirs" })
					)
					vim.keymap.set(
						"n",
						"<A-a>",
						"<Plug>(git-conflict-both)",
						vim.tbl_extend("force", opts, { desc = "Choose Both" })
					)
					vim.keymap.set(
						"n",
						"<A-'>",
						"<Plug>(git-conflict-next-conflict)",
						vim.tbl_extend("force", opts, { desc = "Next Conflict" })
					)
					vim.keymap.set(
						"n",
						"<A-;>",
						"<Plug>(git-conflict-prev-conflict)",
						vim.tbl_extend("force", opts, { desc = "Prev Conflict" })
					)
				end,
			})
		end,
	},
}
