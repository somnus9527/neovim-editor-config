local M = {}

-- Mason v1 需要保证安装的 LSP server 列表，继续沿用升级前的手动启用策略。
local ensure_installed = {
	"lua_ls",
	"vtsls",
	"cssls",
	"bashls",
	"css_variables",
	"cssmodules_ls",
	"html",
	"tailwindcss",
	"jsonls",
	-- 目前 mason-lspconfig 中仍使用旧名称，vue_ls 由用户侧按需安装。
	"svelte",
	"yamlls",
	"clangd",
	"cmake",
	"pyright",
	"ruff",
}

-- 初始化 mason.nvim 本体，保留默认 registry 和安装目录行为。
function M.setup_mason()
	require("mason").setup()
end

-- 配置 mason-lspconfig v1 的自动安装列表，不接管 LSP 启用流程。
function M.setup_lspconfig()
	require("mason-lspconfig").setup({
		ensure_installed = ensure_installed,
		automatic_installation = true,
	})
end

-- 按依赖顺序配置 Mason 相关插件，供 pack 加载器统一调用。
function M.setup()
	M.setup_mason()
	M.setup_lspconfig()
end

return M
