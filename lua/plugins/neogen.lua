return {
	"danymat/neogen",
	event = { "BufNewFile", "BufReadPre" },
	config = function()
		local neogen = require("neogen")
		local tools = require("tools.tools")
		neogen.setup({
			enabled = true,
			input_after_comment = true,
			snippet_engine = "luasnip",
		})
		local keymaps = {
			{
        { "n", "v" },
				"<leader>dc",
				"<cmd>lua require('neogen').generate({ type = 'class' })<cr>",
				{ desc = "Generate Class" },
			},
			{
        { "n", "v" },
				"<leader>df",
				"<cmd>lua require('neogen').generate({ type = 'func' })<cr>",
				{ desc = "Generate Function" },
			},
			{
        { "n", "v" },
				"<leader>dt",
				"<cmd>lua require('neogen').generate({ type = 'type' })<cr>",
				{ desc = "Generate Type" },
			},
		}
		tools.set_keymap(keymaps)
	end,
}
