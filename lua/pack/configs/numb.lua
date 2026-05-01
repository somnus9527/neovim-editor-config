local M = {}

-- 配置 numb.nvim，在行号跳转前展示目标行预览。
function M.setup()
	require("numb").setup({
		show_numbers = true,
		show_cursorline = true,
		hide_relativenumbers = true,
		number_only = false,
		centered_peeking = true,
	})
end

return M
