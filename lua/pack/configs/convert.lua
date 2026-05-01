local M = {}

-- 配置 convert.nvim，启用颜色、尺寸和数字单位转换模式。
function M.setup()
	require("convert").setup({
		modes = { "color", "size", "numbers" },
	})
end

-- 注册单位转换快捷键；首次触发时会走 loaders.lua 中的命令占位加载。
function M.register_keys()
	vim.keymap.set("n", "<leader>cc", "<cmd>ConvertFindCurrent<CR>", {
		desc = "切换当前光标下的单位",
		silent = true,
	})
end

return M
