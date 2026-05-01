local M = {}

local jsx_filetypes = { "typescriptreact", "javascriptreact" }

--[[
判断文件类型是否属于 JSX/TSX 编辑场景。
该函数用于插件按 FileType 懒加载时，补齐当前缓冲区已经触发过 FileType 事件的情况。

入参 filetype：当前缓冲区的文件类型。
返回值：true 表示需要注册 JSX 元素 textobject 键位。
]]
local function is_jsx_filetype(filetype)
	return vim.tbl_contains(jsx_filetypes, filetype)
end

--[[
根据 JSX textobject 查询名创建选择函数。
新版 nvim-treesitter-textobjects main 不再提供旧的 TSTextobjectSelect 命令，
因此这里直接调用模块 API 保留 it/at 的 JSX 元素选择能力。

入参 query_name：textobjects 查询捕获名，例如 @jsx_element.inner。
返回值：可直接绑定到 keymap 的回调函数。
]]
local function create_select_textobject(query_name)
	--[[
	执行指定 JSX 捕获名的 textobject 选择。
	该闭包会在按键触发时加载新版 textobjects select 模块并执行选择。
	]]
	return function()
		require("nvim-treesitter-textobjects.select").select_textobject(query_name, "textobjects")
	end
end

--[[
根据 JSX textobject 查询名创建跳转函数。
该函数替代旧 TSTextobjectGotoNextStart / TSTextobjectGotoPreviousStart 命令。

入参 direction：跳转方向，next 表示下一个节点，previous 表示上一个节点。
入参 query_name：textobjects 查询捕获名。
返回值：可直接绑定到 keymap 的回调函数。
]]
local function create_move_textobject(direction, query_name)
	--[[
	执行指定 JSX 捕获名的 textobject 跳转。
	该闭包根据方向调用新版 textobjects move 模块的前进或后退入口。
	]]
	return function()
		local move = require("nvim-treesitter-textobjects.move")
		if direction == "next" then
			move.goto_next_start(query_name, "textobjects")
		else
			move.goto_previous_start(query_name, "textobjects")
		end
	end
end

--[[
为 JSX/TSX 文件注册 JSX 元素 textobject 快捷键。
键位沿用 jsx-element.nvim 的默认行为：it/at 选择元素，]t/[t 跳转元素。

入参 event：FileType autocmd 事件参数，用于拿到当前缓冲区编号。
返回值：本函数只创建 buffer 局部 keymap，不返回业务数据。
]]
local function register_jsx_element_keymaps(event)
	vim.keymap.set({ "x", "o" }, "it", create_select_textobject("@jsx_element.inner"), {
		buffer = event.buf,
		desc = "选择 JSX 元素内部",
	})
	vim.keymap.set({ "x", "o" }, "at", create_select_textobject("@jsx_element.outer"), {
		buffer = event.buf,
		desc = "选择 JSX 元素整体",
	})
	vim.keymap.set("n", "]t", create_move_textobject("next", "@jsx_element.outer"), {
		buffer = event.buf,
		desc = "跳到下一个 JSX 元素",
	})
	vim.keymap.set("n", "[t", create_move_textobject("previous", "@jsx_element.outer"), {
		buffer = event.buf,
		desc = "跳到上一个 JSX 元素",
	})
end

--[[
配置 jsx-element.nvim 并接管 JSX 元素 textobject 键位。
插件自身仍生成旧 TSTextobject 命令，因此这里只保留查询能力并注册新版 API 键位。

返回值：本函数只初始化插件配置和 FileType 自动命令，不返回业务数据。
]]
function M.setup()
	require("jsx-element").setup({
		keymaps = {
			enable = false,
		},
	})
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("JsxElementTextobjects", { clear = true }),
		pattern = jsx_filetypes,
		callback = register_jsx_element_keymaps,
	})
	if is_jsx_filetype(vim.bo.filetype) then
		register_jsx_element_keymaps({ buf = vim.api.nvim_get_current_buf() })
	end
end

return M
