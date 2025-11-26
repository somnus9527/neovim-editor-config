return {
	"numToStr/Comment.nvim",
	event = { "BufNewFile", "BufReadPre" },
	dependencies = {
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			opts = {
				enable = true,
				enable_autocmd = false,
			},
		},
	},
	init = function()
		vim.g.skip_ts_context_commentstring = true
	end,
	config = function()
		require("Comment").setup({
			-- 这里可以自定义选项
			padding = true, -- 注释后是否加空格
			sticky = true, -- 注释保持在行首
			ignore = nil, -- 忽略某些行
			toggler = {
				line = "gcc", -- 切换行注释
				block = "gvc", -- 切换块注释
			},
			opleader = {
				line = "gc", -- 操作符行注释
				block = "gv", -- 操作符块注释
			},
			extra = {
				above = "gcO", -- 在当前行上方添加注释
				below = "gco", -- 在当前行下方添加注释
				eol = "gcA", -- 在行尾添加注释
			},
			mappings = {
				basic = true, -- 启用基本映射 (gcc, gc{motion}, gb{motion}, gbc, gb)
				extra = true, -- 启用额外映射 (gcO, gco, gcA)
			},
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			post_hook = nil, -- 可选：函数，在注释后执行
		})
	end,
}
