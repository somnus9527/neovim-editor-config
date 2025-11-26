return {
	"stevearc/dressing.nvim",
	opts = {
		input = {
			enabled = true,
			mappings = {
				n = {
					["<Esc>"] = "Close",
					["<CR>"] = "Confirm",
				},
				i = {
					["<A-e>"] = "Close",
					["<CR>"] = "Confirm",
					["<A-k>"] = "HistoryPrev",
					["<A-j>"] = "HistoryNext",
				},
			},
		},
		select = {
			enabled = true,
			backend = { "fzf_lua", "builtin", "nui" },
			fzf_lua = {
				winopts = {
				  height = 0.5,
				  width = 0.9,
				},
			},
		},
	},
}
