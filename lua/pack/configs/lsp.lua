local M = {}

-- 加载当前仓库的原生 LSP 配置，统一注册 server、诊断和 LspAttach 快捷键。
function M.setup()
	require("config.lsp")
end

return M
