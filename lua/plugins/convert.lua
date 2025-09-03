return {
	"cjodo/convert.nvim",
  version = "*",
  ft = { "css", "less", "scss" },
  opts = {
    modes = { "color", "size", "numbers" }
  },
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	keys = {
		-- { "<leader>cn", "<cmd>ConvertFindNext<CR>", desc = "Find next convertable unit" },
		{ "<leader>cc", "<cmd>ConvertFindCurrent<CR>", desc = "切换当前光标下的单位" },
		-- Add "v" to enable converting a selected region
		-- { "<leader>cl", "<cmd>ConvertAll<CR>", mode = { "n", "v" }, desc = "Convert all of a specified unit" },
	},
}
