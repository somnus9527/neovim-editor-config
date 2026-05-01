local M = {}

-- 判断是否跳过 vim.pack.add，供迁移期做无网络、无安装的启动冒烟验证。
local function should_skip_add()
	return vim.env.NVIM_PACK_SKIP_ADD == "1"
end

-- 判断首次安装时是否需要交互确认，headless 场景默认不弹确认。
local function should_confirm()
	if vim.env.NVIM_PACK_CONFIRM == "0" then
		return false
	end

	return #vim.api.nvim_list_uis() > 0
end

-- 启动 vim.pack 管理入口，组装安装清单、构建钩子和已迁移的加载器。
function M.setup()
	require("pack.hooks").setup()

	if not should_skip_add() then
		vim.pack.add(require("pack.specs").all(), {
			load = false,
			confirm = should_confirm(),
		})
	end

	require("pack.loaders").setup({
		configure_plugins = not should_skip_add(),
	})
end

return M
