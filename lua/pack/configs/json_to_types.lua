local M = {}

-- 注册 JSON 转 TypeScript 类型的命令快捷键。
function M.register_keys()
	vim.keymap.set("n", "<leader>ts", "<cmd>ConvertJSONtoLang typescript<CR>", {
		desc = "JSON 转 TS 类型",
		silent = true,
	})
	vim.keymap.set("n", "<leader>tS", "<cmd>ConvertJSONtoLangBuffer typescript<CR>", {
		desc = "JSON 转 TS 类型到缓冲区",
		silent = true,
	})
end

return M
