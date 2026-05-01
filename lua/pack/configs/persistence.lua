local M = {}

-- 配置 persistence.nvim 的 session 存储目录和恢复选项。
function M.setup()
	require("persistence").setup({
		dir = vim.fn.stdpath("state") .. "/sessions/",
		options = { "buffers", "curdir", "tabpages", "winsize" },
		need = 1,
		branch = true,
	})
end

-- 注册 session 快捷键，并通过调用方传入的加载函数保护首次使用路径。
function M.register_keys(load_persistence)
	vim.keymap.set("n", "<leader>sl", function()
		if load_persistence() then
			require("persistence").load({ last = true })
		end
	end, {
		desc = "加载最新的session",
		remap = true,
		silent = true,
	})

	vim.keymap.set("n", "<leader>ss", function()
		if load_persistence() then
			require("persistence").select()
		end
	end, {
		desc = "打开session列表",
		remap = true,
		silent = true,
	})
end

return M
