return {
	"niuiic/git-log.nvim",
	event = { "BufNewFile", "BufReadPre" },
	dependencies = { "niuiic/omega.nvim" },
	opts = {
		extra_args = {},
		window_width_ratio = 0.8,
		window_height_ratio = 0.8,
		quit_key = "q",
	},
	config = function(_, opts)
		local tools = require("tools.tools")
		local keys = {
			{
				{ "n", "v" },
				"<leader>gl",
				function()
					require("git-log").check_log(opts)
				end,
			},
		}
		tools.set_keymap(keys)
	end,
}
