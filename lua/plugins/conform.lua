return {
	"stevearc/conform.nvim",
	lazy = true,
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true })
			end,
			mode = { "n", "v" },
			desc = "格式化",
		},
	},
	opts = {
		formatters_by_ft = {
			-- JavaScript/TypeScript
			javascript = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			typescript = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			javascriptreact = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },
			typescriptreact = { "eslint", "prettier", lsp_format = "fallback", stop_after_first = true },

      -- svelte
      -- svelte = { "eslint_d", "prettier", stop_after_first = true },

			-- CSS / SCSS / Less
			css = { "prettier", lsp_format = "fallback", stop_after_first = true },
			scss = { "prettier", lsp_format = "fallback", stop_after_first = true },
			less = { "prettier", lsp_format = "fallback", stop_after_first = true },

			-- HTML
			html = { "prettier", lsp_format = "fallback", stop_after_first = true },

			-- JSON / YAML
			json = { "prettier", lsp_format = "fallback", stop_after_first = true },
			jsonc = { "prettier", lsp_format = "fallback", stop_after_first = true },
			yaml = { "prettier", lsp_format = "fallback", stop_after_first = true },

			-- Markdown
			markdown = { "prettier", lsp_format = "fallback", stop_after_first = true },

			-- Lua
			lua = { "stylua", lsp_format = "fallback", stop_after_first = true },

      -- 其它
      ["_"] = { lsp_format = "fallback", "trim_whitespace", stop_after_first = true },
		},

		-- 自动保存时格式化
		format_on_save = false,

		-- 允许同时使用多个格式化器，按顺序尝试
		retry_last = true,

		-- 打印调试信息
		log_level = vim.log.levels.ERROR,
	},
}
