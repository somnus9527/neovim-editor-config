return {
	"Exafunction/windsurf.vim",
	event = "BufEnter",
	config = function()
		local tools = require("tools.tools")
		local keymaps = {
			{
				"i",
				"<C-y>",
				function()
					return vim.fn["codeium#Accept"]()
				end,
				{ expr = true, silent = true },
			},
			{
				"i",
				"<C-.>",
				function()
					return vim.fn["codeium#CycleCompletions"](1)
				end,
				{ expr = true, silent = true },
			},
			{
				"i",
				"<C-,>",
				function()
					return vim.fn["codeium#CycleCompletions"](-1)
				end,
				{ expr = true, silent = true },
			},
			{
				"i",
				"<C-x>",
				function()
					return vim.fn["codeium#Clear"]()
				end,
				{ expr = true, silent = true },
			},
			{
				"i",
				"<C-/>",
				function()
					return vim.fn["codeium#Complete"]()
				end,
				{ expr = true, silent = true },
			},
			{
				"i",
				"<C-[>",
				function()
					return vim.fn["codeium#AcceptNextWord"]()
				end,
				{ expr = true, silent = true },
			},
			{
				"i",
				"<C-]>",
				function()
					return vim.fn["codeium#AcceptNextLine"]()
				end,
				{ expr = true, silent = true },
			},
		}
		tools.set_keymap(keymaps)
	end,
}
