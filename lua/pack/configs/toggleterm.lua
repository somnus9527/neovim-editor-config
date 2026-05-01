local M = {}

-- 根据终端方向返回打开尺寸，横向固定高度，纵向使用窗口宽度比例。
local function get_terminal_size(term)
	if term.direction == "horizontal" then
		return 20
	end

	if term.direction == "vertical" then
		return vim.o.columns * 0.4
	end
end

-- 创建并打开指定方向的 toggleterm 终端。
local function open_terminal(name, size, direction)
	local Terminal = require("toggleterm.terminal").Terminal
	Terminal:new({ display_name = name }):toggle(size, direction)
end

-- 打开垂直终端，供历史全局函数和快捷键复用。
local function open_vertical_terminal(name)
	open_terminal(name, vim.o.columns * 0.4, "vertical")
end

-- 打开水平终端，供历史全局函数和快捷键复用。
local function open_horizontal_terminal(name)
	open_terminal(name, 20, "horizontal")
end

-- 切换所有已经存在的 toggleterm 终端窗口。
local function toggle_all_terminals()
	vim.api.nvim_command("ToggleTermToggleAll")
end

-- 展示当前所有 toggleterm 终端列表。
local function list_terminals()
	vim.api.nvim_command("TermSelect")
end

-- 提示用户输入名称后创建具名终端。
local function open_named_terminal(direction)
	local term_name = vim.fn.input("请输入终端名称：")
	if term_name == "" then
		print("终端名称不能为空!")
		return
	end

	if direction == "vertical" then
		open_vertical_terminal(term_name)
	else
		open_horizontal_terminal(term_name)
	end
end

-- 删除当前终端 buffer，作为终端模式下的快速关闭入口。
local function kill_current_terminal()
	vim.api.nvim_buf_delete(0, { force = true })
end

-- 暴露历史全局函数，避免用户已有命令或临时调用路径失效。
local function setup_global_helpers()
	_G._VTerm = open_vertical_terminal
	_G._HTerm = open_horizontal_terminal
	_G._ToggleTerm = toggle_all_terminals
	_G._ListTerm = list_terminals
	_G._NamedVTerm = function()
		open_named_terminal("vertical")
	end
	_G._NamedHTerm = function()
		open_named_terminal("horizontal")
	end
	_G._KillTerm = kill_current_terminal
end

-- 注册终端相关快捷键，保留原有 Alt 系列交互。
local function setup_keymaps()
	vim.keymap.set({ "n", "t" }, "<A-\\>", open_vertical_terminal, { silent = true, desc = "新开一个垂直终端" })
	vim.keymap.set({ "n", "t" }, "<A-/>", open_horizontal_terminal, { silent = true, desc = "新开一个水平终端" })
	vim.keymap.set({ "n", "t" }, "<A-i>", toggle_all_terminals, { silent = true, desc = "切换所有终端" })
	vim.keymap.set("t", "<A-x>", kill_current_terminal, { silent = true, noremap = true, desc = "杀死当前终端" })
end

-- 配置 toggleterm.nvim，并注册历史全局函数和快捷键入口。
function M.setup()
	require("toggleterm").setup({
		size = get_terminal_size,
		direction = "vertical",
		open_mapping = false,
		shade_terminals = true,
		start_in_insert = true,
		persist_size = false,
		winbar = {
			enabled = true,
		},
	})
	setup_global_helpers()
	setup_keymaps()
end

return M
