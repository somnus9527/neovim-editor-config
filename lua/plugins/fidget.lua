return {
	"j-hui/fidget.nvim",
	version = "*", -- alternatively, pin this to a specific version, e.g., "1.6.1"
	opts = {
		-- options
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
	},
}
