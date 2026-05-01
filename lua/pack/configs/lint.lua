local M = {}

-- 判断当前项目根目录是否存在 ESLint 配置文件。
local function has_eslint_config()
	local config_files = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		".eslintrc.yaml",
		".eslintrc.yml",
		"eslint.config.js",
		"eslint.config.cjs",
		"eslint.config.mjs",
		"eslint.config.ts",
	}

	for _, file in ipairs(config_files) do
		if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. file) == 1 then
			return true
		end
	end

	return false
end

-- 优先返回项目本地 eslint，可执行文件不存在时回退到全局 eslint。
local function resolve_eslint_cmd()
	local local_binary = vim.fn.getcwd() .. "/node_modules/.bin/eslint"
	return vim.fn.executable(local_binary) == 1 and local_binary or "eslint"
end

-- 配置 ESLint 命令路径，使项目本地依赖优先于全局命令。
local function configure_eslint(lint, has_config)
	if has_config then
		lint.linters.eslint.cmd = resolve_eslint_cmd
	end
end

-- 根据当前项目是否存在 ESLint 配置构造 filetype 到 linter 的映射。
local function build_linters_by_ft(has_config)
	return {
		javascript = has_config and { "eslint" } or {},
		typescript = has_config and { "eslint" } or {},
		javascriptreact = has_config and { "eslint" } or {},
		typescriptreact = has_config and { "eslint" } or {},
		svelte = has_config and { "eslint_d" } or {},
		vue = has_config and { "eslint" } or {},
		lua = { "luacheck" },
		c = { "clangtidy" },
		cpp = { "clangtidy" },
	}
end

-- 对当前 buffer 执行一次 lint；该函数作为 autocmd 回调使用。
local function try_lint_current_buffer()
	require("lint").try_lint()
end

-- 初始化 nvim-lint，并注册读写和文本变更后的 lint 触发器。
function M.setup()
	local lint = require("lint")
	local has_config = has_eslint_config()

	configure_eslint(lint, has_config)
	lint.linters_by_ft = build_linters_by_ft(has_config)

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
		group = vim.api.nvim_create_augroup("UserPackLint", { clear = true }),
		callback = try_lint_current_buffer,
	})
end

-- 供格式化流程在 conform 完成后复用的手动 lint 入口。
function M.try_lint()
	require("lint").try_lint()
end

return M
