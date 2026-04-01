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
		attach_navic = false,
		exclude_filetypes = {
			"neo-tree",
			"toggleterm",
			"qf",
			"trouble",
		},
	},
}
