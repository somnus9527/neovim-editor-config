local M = {}

-- 配置 nvim-scrollbar，保留诊断标记和常见弹窗 filetype 排除列表。
function M.setup()
	require("scrollbar").setup({
		show = true,
		show_in_active_only = false,
		set_highlights = true,
		folds = 1000,
		max_lines = false,
		hide_if_all_visible = false,
		throttle_ms = 100,
		handle = {
			text = " ",
			blend = 30,
			color = "gray",
			color_nr = nil,
			highlight = "CursorColumn",
			hide_if_all_visible = true,
		},
		excluded_buftypes = {
			"terminal",
		},
		excluded_filetypes = {
			"blink-cmp-menu",
			"dropbar_menu",
			"dropbar_menu_fzf",
			"DressingInput",
			"cmp_docs",
			"cmp_menu",
			"noice",
			"prompt",
			"TelescopePrompt",
		},
		autocmd = {
			render = {
				"BufWinEnter",
				"TabEnter",
				"TermEnter",
				"WinEnter",
				"CmdwinLeave",
				"TextChanged",
				"VimResized",
				"WinScrolled",
			},
			clear = {
				"BufWinLeave",
				"TabLeave",
				"TermLeave",
				"WinLeave",
			},
		},
		handlers = {
			cursor = true,
			diagnostic = true,
			gitsigns = false,
			handle = true,
			search = false,
			ale = false,
		},
	})
end

return M
