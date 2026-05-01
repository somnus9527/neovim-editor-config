local M = {}

-- 注册 bookmarks.nvim 的本地书签快捷键。
local function setup_keymaps()
	local bm = require("bookmarks")
	vim.keymap.set("n", "mm", bm.bookmark_toggle, { desc = "切换当前行书签" })
	vim.keymap.set("n", "ma", bm.bookmark_ann, { desc = "编辑当前行书签注释" })
	vim.keymap.set("n", "mx", bm.bookmark_clean, { desc = "清理当前 buffer 书签" })
	vim.keymap.set("n", "mn", bm.bookmark_next, { desc = "跳到下一个书签" })
	vim.keymap.set("n", "mp", bm.bookmark_prev, { desc = "跳到上一个书签" })
	vim.keymap.set("n", "ml", bm.bookmark_list, { desc = "打开书签列表" })
	vim.keymap.set("n", "mc", bm.bookmark_clear_all, { desc = "清空所有书签" })
end

-- 配置 bookmarks.nvim，保留原有书签文件位置和注释关键字图标。
function M.setup()
	require("bookmarks").setup({
		save_file = vim.fn.expand("$HOME/.bookmarks"),
		keywords = {
			["@t"] = "☑️ ",
			["@w"] = "⚠️ ",
			["@f"] = "⛏ ",
			["@n"] = " ",
		},
		on_attach = setup_keymaps,
	})
end

return M
