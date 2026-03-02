-- 已禁用: 与 noice.nvim 冲突，noice.nvim 提供更完整的UI美化解决方案
-- WARN: 重新装回来了，因为现在发现不装这个会导致codecompanion在需要确认时直接取消，不知道什么原因
return {
	"vzze/cmdline.nvim",
	event = { "CmdlineEnter", "CmdlineChanged" },
	opts = {
		cmdtype = ":", -- you can also add / and ? by using ":/?"
		-- as a string

		window = {
			matchFuzzy = true,
			offset = 1, -- depending on 'cmdheight' you might need to offset
			debounceMs = 10, -- the lower the number the more responsive however
			-- more resource intensive
		},

		hl = {
			default = "Pmenu",
			selection = "PmenuSel",
			directory = "Directory",
			substr = "LineNr",
		},

		column = {
			maxNumber = 6,
			minWidth = 20,
		},

		binds = {
			next = "<Tab>",
			back = "<S-Tab>",
		},
	},
	config = true,
}
