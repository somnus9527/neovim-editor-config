local M = {}

-- 同步执行构建命令，确保 headless 安装退出前构建产物已经落盘。
local function run_build_command(cmd, path)
	local result = vim.system(cmd, { cwd = path, text = true }):wait()

	if result.code ~= 0 then
		vim.notify(
			("vim.pack 构建失败：%s\n%s"):format(table.concat(cmd, " "), result.stderr or ""),
			vim.log.levels.ERROR
		)
	end
end

--[[
定义插件安装和更新后的构建动作。
]]
local build_handlers = {
	["LuaSnip"] = function(path)
		run_build_command({ "make", "install_jsregexp" }, path)
	end,
	["json-to-types.nvim"] = function(path)
		run_build_command({ "sh", "install.sh", "npm" }, path)
	end,
	["nvim-treesitter"] = function()
		vim.cmd.packadd("nvim-treesitter")
		vim.cmd("TSUpdateSync")
	end,
}

--[[
判断当前 Neovim 是否支持 vim.pack 的 PackChanged 事件。
Neovim 0.11.5 尚未暴露该 autocmd，直接注册会中断后续主题和插件加载。

返回值：支持该事件返回 true；不支持时返回 false。
]]
local function supports_pack_changed_event()
	local ok = pcall(vim.api.nvim_get_autocmds, { event = "PackChanged" })
	return ok
end

-- 注册 vim.pack 的构建钩子，仅在插件安装或更新后触发。
function M.setup()
	if not supports_pack_changed_event() then
		return
	end

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("UserPackBuildHooks", { clear = true }),
		callback = function(ev)
			local data = ev.data or {}
			local spec = data.spec or {}
			local handler = build_handlers[spec.name]

			if handler and (data.kind == "install" or data.kind == "update") then
				handler(data.path)
			end
		end,
	})
end

return M
