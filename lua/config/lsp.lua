local icons_ok, icons = pcall(require, "config.icons")
if not icons_ok then
	return
end

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
	return
end

local mason_opt = {
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
}
mason.setup(mason_opt)

local mason_lsp_ok, mason_lsp = pcall(require, "mason-lspconfig")
if not mason_lsp_ok then
	return
end

local mason_lsp_opt = {
	ensure_installed = {
		"lua_ls",
		"eslint",
		"tsserver",
		"cssls",
		"cssmodules_ls",
		"css_variables",
		"html",
		"jsonls",
		"marksman",
		"tailwindcss",
		"svelte",
		"taplo",
		"volar",
		"yamlls",
		"emmet_ls",
	},
}
mason_lsp.setup(mason_lsp_opt)

local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_lsp_ok then
	return
end

-- 获取优化版lsp-cmp capabilities
local capabilities = cmp_lsp.default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
	return
end

-- 配置diagnostics图标
for name, icon in pairs(icons.diagnostics) do
	local diagnostic_name = "DiagnosticSign" .. name
	vim.fn.sign_define(diagnostic_name, { texthl = diagnostic_name, text = icon, numhl = "" })
end
-- diagnostics配置
local config = {
	virtual_text = false,
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
}
vim.diagnostic.config(config)
-- 配置hover样式
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
-- 配置signatureHelp样式
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
})

-- 配置 eslint 为 JavaScript、JSX、TypeScript、TSX、Vue 文件的诊断工具
lspconfig.eslint.setup({
	capabilities = capabilities,
	-- 确保 eslint 仅在以下文件类型上启用
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
	},
})

-- 开始服务配置
lspconfig.lua_ls.setup({
	capabilities = capabilities,
	-- 主要处理undefinded global vim 报错, 方案来自https://github.com/neovim/neovim/discussions/24119
	on_init = function(client)
		local path = client.workspace_folders[1].name
		if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
						},
					},
				},
			})
		end
		return true
	end,
})

-- 前置安装 npm install emmet-ls -g
lspconfig.emmet_ls.setup({
	capabilities = capabilities,
	filetypes = {
		"css",
		"html",
		"javascript",
		"javascriptreact",
		"less",
		"sass",
		"scss",
		"svelte",
		"pub",
		"typescriptreact",
		"vue",
	},
	init_options = {
		html = {
			options = {
				["bem.enabled"] = true,
			},
		},
	},
})

-- 为其他文件配置通用的 LSP 客户端
local servers = {
	"tsserver",
	"cssls",
	"cssmodules_ls",
	"css_variables",
	"html",
	"jsonls",
	"marksman",
	"tailwindcss",
	"svelte",
	"taplo",
	"volar",
	"yamlls",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		capabilities = capabilities,
	})
end

local lsp_formatting = function(buffer)
	-- 使用当前缓冲区编号作为默认值
	buffer = buffer or vim.api.nvim_get_current_buf()
	-- 获取当前文件类型
	local filetype = vim.api.nvim_buf_get_option(buffer, "filetype")
	local supported_filetypes =
		{ "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "json", "lua" }
	local is_support = false
	for _, ft in ipairs(supported_filetypes) do
		if filetype == ft then
			is_support = true
		end
	end
	if is_support then
		pcall(vim.api.nvim_command, "Format")
	else
		vim.lsp.buf.format({
			bufnr = buffer,
			timeout_ms = 20000,
		})
	end
end

-- 其余lspserver相关配置
-- 快捷键配置
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		local extend = function(opt)
			local re_opt = {}
			if opt then
				re_opt = vim.tbl_deep_extend("force", opts, opt)
			end
			return re_opt
		end

		local map = vim.keymap
		map.set("n", "gd", vim.lsp.buf.definition, extend({ desc = "跳转Definition" }))
		map.set("n", "gD", vim.lsp.buf.declaration, extend({ desc = "跳转Declaration" }))
		map.set("n", "gr", vim.lsp.buf.references, extend({ desc = "显示References" }))
		map.set("n", "gi", vim.lsp.buf.implementation, extend({ desc = "显示Implementation" }))
		map.set("n", "<leader>r", vim.lsp.buf.rename, extend({ desc = "重命名" }))
		map.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
		map.set("n", "<leader>f", lsp_formatting, { desc = "Format" })
		map.set("n", "K", vim.lsp.buf.hover, extend({ desc = "Hover展示代码说明" }))
		map.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", extend({ desc = "展示报错详情" }))
	end,
})
