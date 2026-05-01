local M = {}

-- 复用历史启动期 statusline 处理，避免 lualine 加载前界面闪烁。
function M.apply_startup_statusline()
	vim.g.lualine_laststatus = vim.o.laststatus
	if vim.fn.argc(-1) > 0 then
		vim.o.statusline = " "
	else
		vim.o.laststatus = 0
	end
end

-- 配置 lualine，并复用仓库现有的状态栏配置表。
function M.setup()
	local opts = require("config.lualine-conf")

	require("lualine").setup(opts)
end

return M
