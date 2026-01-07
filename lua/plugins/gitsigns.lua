return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local gitsigns = require("gitsigns")
		local icons = require("tools.icons").git

		gitsigns.setup({
			signs = {
				add = { text = icons.added },
				change = { text = icons.modified },
				delete = { text = icons.removed },
				topdelete = { text = icons.topdelete },
				changedelete = { text = icons.changedelete },
				attach_to_untracked = { text = icons.untracked },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 200,
				use_focus = true,
				relative_time = false,
			},
			current_line_blame_formatter = "<author>, <author_mail>, <author_time:%Y-%m-%d %H:%M:%S> - <summary>",
			signcolumn = true,
			numhl = true,
			linehl = false,
			word_diff = false,
			watch_gitdir = {
				enable = true,
				interval = 1000,
				follow_files = true,
			},
			diff_opts = { internal = false },
			max_file_length = 20000,
			attach_to_untracked = false,
			update_debounce = 200,
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local map = vim.keymap.set

				-- 当前行 Blame
				-- map("n", "<leader>gh", gs.show_line_blame, { buffer = bufnr, desc = "Git Blame 当前行" })
				map(
					"n",
					"<leader>gb",
					gs.toggle_current_line_blame,
					{ buffer = bufnr, desc = "Toggle 当前行 Blame" }
				)

				-- 快速跳转修改
				-- Navigation
				map("n", "]]", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end)

				map("n", "[[", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end)
			end,
		})
	end,
}
