local M = {}

-- 聚焦刚创建的 Trouble 窗口，让当前 buffer 诊断列表可直接操作。
local function focus_trouble_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "trouble" then
			vim.api.nvim_set_current_win(win)
			break
		end
	end
end

-- 返回当前 buffer 诊断切换回调，首次触发时会先加载 trouble.nvim。
local function create_buffer_diagnostics_callback(load_trouble)
	-- 这个闭包是实际 keymap 回调，用于切换当前 buffer 的诊断列表。
	return function()
		if load_trouble() then
			vim.cmd("Trouble diagnostics toggle filter.buf=0")
			vim.defer_fn(focus_trouble_window, 50)
		end
	end
end

-- 返回工作区诊断切换回调，首次触发时会先加载 trouble.nvim。
local function create_workspace_diagnostics_callback(load_trouble)
	-- 这个闭包是实际 keymap 回调，用于切换工作区诊断列表。
	return function()
		if load_trouble() then
			vim.cmd("Trouble diagnostics toggle")
		end
	end
end

-- 配置 trouble.nvim，保留符号列表宽度和回车后跳转关闭行为。
function M.setup()
	require("trouble").setup({
		modes = {
			symbols = {
				win = {
					size = 100,
					position = "right",
				},
			},
		},
		keys = {
			o = nil,
			["<cr>"] = "jump_close",
		},
	})
end

-- 注册 Trouble 的当前 buffer 与工作区诊断快捷键。
function M.register_keys(load_trouble)
	vim.keymap.set("n", "<leader>xx", create_buffer_diagnostics_callback(load_trouble), {
		desc = "当前Buffer的Diagnostics",
		silent = true,
	})
	vim.keymap.set("n", "<leader>xX", create_workspace_diagnostics_callback(load_trouble), {
		desc = "当前Workspace的Diagnostics",
		silent = true,
	})
end

return M
