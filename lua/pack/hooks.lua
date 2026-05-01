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

-- 定义从 lazy.nvim build 字段迁移过来的安装和更新后构建动作。
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

-- 注册 vim.pack 的构建钩子，仅在插件安装或更新后触发。
function M.setup()
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
