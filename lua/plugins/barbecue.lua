return {
	"utilyre/barbecue.nvim",
	name = "barbecue",
	event = { "BufNewFile", "BufReadPre" },
	version = "*",
	dependencies = {
		"SmiteshP/nvim-navic",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		exclude_filetypes = {
			"neo-tree",
			"toggleterm",
			"qf",
			"trouble",
		},
	},
}
