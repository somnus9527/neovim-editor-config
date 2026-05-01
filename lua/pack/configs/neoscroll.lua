local M = {}

-- 向下平滑滚动一段距离，并同步移动光标位置。
local function scroll_down()
	require("neoscroll").scroll(0.8, { move_cursor = true, duration = 100 })
end

-- 向上平滑滚动一段距离，并同步移动光标位置。
local function scroll_up()
	require("neoscroll").scroll(-0.8, { move_cursor = true, duration = 100 })
end

-- 注册 neoscroll 的滚动快捷键，覆盖普通、可视和选择模式。
local function setup_keymaps()
	local modes = { "n", "v", "x" }
	vim.keymap.set(modes, "<A-1>", scroll_down, { silent = true, desc = "向下平滑滚动" })
	vim.keymap.set(modes, "<A-2>", scroll_up, { silent = true, desc = "向上平滑滚动" })
end

-- 配置 neoscroll.nvim，保留二次滚动缓动和隐藏光标策略。
function M.setup()
	require("neoscroll").setup({
		hide_cursor = true,
		easing = "quadratic",
	})
	setup_keymaps()
end

return M
