local M = {}

-- 生成指定类型的注释模板，封装后供多个快捷键复用。
local function generate_comment(comment_type)
	require("neogen").generate({ type = comment_type })
end

-- 注册 neogen 的类、函数和类型注释生成快捷键。
local function setup_keymaps()
	vim.keymap.set({ "n", "v" }, "<leader>dc", function()
		generate_comment("class")
	end, { desc = "生成类注释", silent = true })
	vim.keymap.set({ "n", "v" }, "<leader>df", function()
		generate_comment("func")
	end, { desc = "生成函数注释", silent = true })
	vim.keymap.set({ "n", "v" }, "<leader>dt", function()
		generate_comment("type")
	end, { desc = "生成类型注释", silent = true })
end

-- 配置 neogen，使用 LuaSnip 作为片段引擎并保留注释后进入输入的行为。
function M.setup()
	require("neogen").setup({
		enabled = true,
		input_after_comment = true,
		snippet_engine = "luasnip",
	})
	setup_keymaps()
end

return M
