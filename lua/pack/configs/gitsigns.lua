local M = {}

-- 跳到下一个 Git hunk；diff 模式下保留原生 ]c 行为。
local function next_hunk()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		require("gitsigns").nav_hunk("next")
	end
end

-- 跳到上一个 Git hunk；diff 模式下保留原生 [c 行为。
local function previous_hunk()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		require("gitsigns").nav_hunk("prev")
	end
end

-- 为已经附着的 Git buffer 注册 blame 切换和 hunk 跳转快捷键。
local function on_attach(bufnr)
	local gitsigns = require("gitsigns")
	local map = vim.keymap.set

	map("n", "<leader>gb", gitsigns.toggle_current_line_blame, {
		buffer = bufnr,
		desc = "Toggle 当前行 Blame",
	})
	map("n", "]]", next_hunk, {
		buffer = bufnr,
		desc = "跳到下一个 Git hunk",
	})
	map("n", "[[", previous_hunk, {
		buffer = bufnr,
		desc = "跳到上一个 Git hunk",
	})
end

-- 配置 gitsigns，提供 Git 符号列、当前行 blame 和 hunk 导航。
function M.setup()
	local icons = require("tools.icons").git

	require("gitsigns").setup({
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
			enable = false,
			interval = 1000,
			follow_files = true,
		},
		diff_opts = { internal = false },
		max_file_length = 4000,
		attach_to_untracked = false,
		update_debounce = 2000,
		on_attach = on_attach,
	})
end

return M
