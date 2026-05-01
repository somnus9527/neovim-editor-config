local M = {}

local default_opts = {
	extra_args = {},
	window_width_ratio = 0.8,
	window_height_ratio = 0.8,
	quit_key = "q",
}

-- 返回打开当前行或选区 Git 日志的 keymap 回调。
local function create_open_log_callback(opts)
	-- 这个闭包是实际 keymap 回调，用于把当前范围交给 git-log.nvim。
	return function()
		require("git-log").check_log(opts)
	end
end

-- 注册 git-log.nvim 的当前行或选区日志入口。
function M.setup()
	vim.keymap.set({ "n", "v" }, "<leader>gl", create_open_log_callback(default_opts), {
		desc = "当前行或选中行日志",
		silent = true,
	})
end

return M
