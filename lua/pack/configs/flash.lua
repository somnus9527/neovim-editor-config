local M = {}

--[[
创建 Flash 动作快捷键回调。
首次触发时先通过调用方加载 flash.nvim，再执行 jump 或 treesitter 跳转。

入参 load_flash：加载 flash.nvim 的函数，成功时返回 true。
入参 action_name：flash.nvim 暴露的动作名，例如 jump 或 treesitter。
返回值：可直接绑定到 keymap 的回调函数。
]]
local function create_flash_callback(load_flash, action_name)
	return function()
		if load_flash() then
			require("flash")[action_name]()
		end
	end
end

--[[
注册 Flash 的跳转快捷键。
这里保留历史配置中的 ss 和 sS，不注册插件默认 s/S 入口，避免覆盖普通编辑语义。

入参 load_flash：加载 flash.nvim 的函数，成功时返回 true。
返回值：本函数只注册 keymap，不返回业务数据。
]]
function M.register_keys(load_flash)
	vim.keymap.set({ "n", "x", "o" }, "ss", create_flash_callback(load_flash, "jump"), {
		desc = "Flash 跳转",
		silent = true,
	})
	vim.keymap.set({ "n", "x", "o" }, "sS", create_flash_callback(load_flash, "treesitter"), {
		desc = "Flash Treesitter 跳转",
		silent = true,
	})
end

return M
