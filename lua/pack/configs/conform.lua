local M = {}

-- 根据 ruff_format 是否可用选择 Python 格式化链。
local function select_python_formatters(bufnr)
	if require("conform").get_formatter_info("ruff_format", bufnr).available then
		return { "ruff_format" }
	end

	return { "isort", "black" }
end

-- 构造 conform.nvim 配置，保留各语言格式化器顺序和 fallback 策略。
local function build_options()
	return {
		formatters_by_ft = {
			javascript = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			typescript = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			javascriptreact = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			typescriptreact = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			svelte = { "prettier", stop_after_first = true },
			vue = { "eslint", "prettier", stop_after_first = true },
			css = { "prettier", lsp_format = "fallback", stop_after_first = true },
			scss = { "prettier", lsp_format = "fallback", stop_after_first = true },
			less = { "prettier", lsp_format = "fallback", stop_after_first = true },
			html = { "prettier", lsp_format = "fallback", stop_after_first = true },
			json = { "prettier", lsp_format = "fallback", stop_after_first = true },
			jsonc = { "prettier", lsp_format = "fallback", stop_after_first = true },
			yaml = { "prettier", lsp_format = "fallback", stop_after_first = true },
			markdown = { "prettier", lsp_format = "fallback", stop_after_first = true },
			lua = { "stylua", lsp_format = "fallback", stop_after_first = true },
			c = { "clang-format" },
			cpp = { "clang-format" },
			python = select_python_formatters,
			["_"] = { lsp_format = "fallback", "trim_whitespace", stop_after_first = true },
		},
		format_on_save = false,
		retry_last = true,
		log_level = vim.log.levels.ERROR,
	}
end

-- 返回 conform 格式化结束后的 lint 回调，首次格式化时会按需加载 nvim-lint。
local function create_lint_callback(load_lint)
	-- 这个闭包是 conform.nvim 的完成回调，用于格式化后触发一次 lint。
	return function()
		if load_lint and load_lint() then
			require("lint").try_lint()
		end
	end
end

-- 初始化 conform.nvim，注册各语言格式化器。
function M.setup()
	require("conform").setup(build_options())
end

-- 执行当前 buffer 格式化，并在格式化完成后尝试触发 lint。
function M.format_with_lint(load_lint)
	require("conform").format({ async = true, lsp_format = "fallback" }, create_lint_callback(load_lint))
end

return M
