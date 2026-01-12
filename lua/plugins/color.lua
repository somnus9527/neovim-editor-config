return {
	"catgoose/nvim-colorizer.lua",
	event = "VeryLazy",
	opts = {
    lazy_load = true,
		user_default_options = {
			rgb_fn = true,
			hsl_fn = true,
			css = true,
			tailwind = "lsp",
			sass = {
				enable = true,
				parsers = {
					"css",
				},
			},
		},
	},
}
