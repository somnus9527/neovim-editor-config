local M = {}

-- 配置 mini.splitjoin，保留当前 <leader>q 的分割与合并切换入口。
function M.setup()
	require("mini.splitjoin").setup({
		mappings = {
			toggle = "<leader>q",
		},
	})
end

return M
