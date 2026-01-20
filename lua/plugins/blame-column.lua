return {
	"Yu-Leo/blame-column.nvim",
	opts = {
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
	},
	cmd = "BlameColumnToggle",
}
