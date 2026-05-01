local M = {}

-- 配置 diffview.nvim 的差异视图、冲突处理和文件面板快捷键。
function M.setup()
	local actions = require("diffview.actions")

	require("diffview").setup({
		enhanced_diff_hl = true,
		view = {
			default = {
				layout = "diff2_horizontal",
			},
			merge_tool = {
				layout = "diff3_horizontal",
				disable_diagnostics = false,
			},
			file_history = {
				layout = "diff2_horizontal",
			},
		},
		file_panel = {
			listing_style = "list",
		},
		keymaps = {
			disable_defaults = true,
			view = {
				{ "n", "<Tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
				{ "n", "<S-Tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
				{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new tab page" } },
				{ "n", "<A-`>", actions.cycle_layout, { desc = "Cycle through available layouts" } },
				{ "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
				{ "n", "<A-'>", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
				{ "n", "<A-;>", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
				{ "n", "<A-o>", actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
				{ "n", "<A-t>", actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
				{ "n", "<A-b>", actions.conflict_choose("base"), { desc = "Choose the Base version of a conflict" } },
				{ "n", "<A-a>", actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
				{ "n", "dx", actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
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
					"<A-B>",
					actions.conflict_choose_all("base"),
					{ desc = "Choose the Base version of a conflict" },
				},
				{
					"n",
					"<A-A>",
					actions.conflict_choose_all("all"),
					{ desc = "Choose all the versions of a conflict for the whole file" },
				},
			},
			diff1 = {
				{ "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
			},
			diff2 = {
				{ "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
			},
			diff3 = {
				{ "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
				{
					{ "n", "x" },
					"doo",
					actions.diffget("ours"),
					{ desc = "Obtain the diff hunk from the OURS version of the file" },
				},
				{
					{ "n", "x" },
					"dot",
					actions.diffget("theirs"),
					{ desc = "Obtain the diff hunk from the THEIRS version of the file" },
				},
			},
			diff4 = {
				{ "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
				{
					{ "n", "x" },
					"doo",
					actions.diffget("ours"),
					{ desc = "Obtain the diff hunk from the OURS version of the file" },
				},
				{
					{ "n", "x" },
					"dot",
					actions.diffget("theirs"),
					{ desc = "Obtain the diff hunk from the THEIRS version of the file" },
				},
				{
					{ "n", "x" },
					"dob",
					actions.diffget("base"),
					{ desc = "Obtain the diff hunk from the BASE version of the file" },
				},
			},
			file_panel = {
				{ "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
				{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
				{ "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry" } },
				{ "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
				{ "n", "S", actions.stage_all, { desc = "Stage all entries" } },
				{ "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
				{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
				{ "n", "<A-2>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
				{ "n", "<A-1>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
				{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new tab page" } },
				{ "n", "i", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
				{ "n", "f", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories in tree listing style" } },
				{ "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list" } },
				{ "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
				{ "n", "<A-`>", actions.cycle_layout, { desc = "Cycle through available layouts" } },
				{ "n", "<A-'>", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
				{ "n", "<A-;>", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
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
				{ "n", "<A-B>", actions.conflict_choose_all("base"), { desc = "Choose the Base version of a conflict" } },
				{
					"n",
					"<A-A>",
					actions.conflict_choose_all("all"),
					{ desc = "Choose all the versions of a conflict for the whole file" },
				},
				{ "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
				{ "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
			},
			file_history_panel = {
				{ "n", "g!", actions.options, { desc = "Open the option panel" } },
				{
					"n",
					"<C-d>",
					actions.open_in_diffview,
					{ desc = "Open the entry under the cursor in a diffview" },
				},
				{ "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
				{ "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
				{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
				{ "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
				{ "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
				{ "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry" } },
				{ "n", "<A-2>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
				{ "n", "<A-1>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
				{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new tab page" } },
				{ "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
				{ "n", "<A-`>", actions.cycle_layout, { desc = "Cycle through available layouts" } },
				{ "n", "X", actions.restore_entry, { desc = "Restore file to the state from the selected entry" } },
				{ "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
			},
			option_panel = {
				{ "n", "s", actions.select_entry, { desc = "Change the current option" } },
				{ "n", "q", actions.close, { desc = "Close the panel" } },
				{ "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
			},
			help_panel = {
				{ "n", "q", actions.close, { desc = "Close help menu" } },
			},
		},
	})
end

-- 注册 diffview 的常用命令入口快捷键，命令本身由 loaders.lua 占位加载。
function M.register_keys()
	vim.keymap.set("n", "<A-`>", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open", silent = true })
	vim.keymap.set("n", "<A-q>", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close", silent = true })
	vim.keymap.set("n", "<A-e>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Diffview Files Toggle", silent = true })
	vim.keymap.set("n", "<A-h>", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview Files History", silent = true })
end

return M
