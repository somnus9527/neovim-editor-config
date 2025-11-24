return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		options = { "buffers", "curdir", "tabpages", "winsize" },
		need = 1,
		branch = true,
	},
	keys = {
		{
			"<leader>sl",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "加载最新的session",
			remap = true,
		},
		{
			"<leader>ss",
			function()
				require("persistence").select()
			end,
			desc = "打开session列表",
			remap = true,
		},
	},
}
