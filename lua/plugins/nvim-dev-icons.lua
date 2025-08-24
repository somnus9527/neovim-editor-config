return {
	"nvim-tree/nvim-web-devicons",
	lazy = "VeryLazy",
	config = function(_, opts)
		local devicons = require("nvim-web-devicons")
		devicons.setup(opts)

		devicons.set_icon({
			css = {
				icon = "",
				color = "#563d7c",
				name = "Css",
			},
		})
	end,
}
