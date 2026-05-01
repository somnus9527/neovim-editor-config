local M = {}

-- 配置 copy_with_context.nvim，保留相对路径和绝对路径两种复制入口。
function M.setup()
	require("copy_with_context").setup({
		mappings = {
			relative = "<leader>cy",
			absolute = "<leader>cY",
		},
		trim_lines = false,
		context_format = "# %s:%s",
	})
end

return M
