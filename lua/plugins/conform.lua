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
			javascript = { "eslint_d", "prettier", stop_after_first = true },
			typescript = { "eslint_d", "prettier", stop_after_first = true },
			javascriptreact = { "eslint_d", "prettier", stop_after_first = true },
			typescriptreact = { "eslint_d", "prettier", stop_after_first = true },

			-- CSS / SCSS / Less
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },

			-- HTML
			html = { "prettier" },

			-- JSON / YAML
			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "prettier" },

			-- Markdown
			markdown = { "prettier" },

			-- Lua
			lua = { "stylua" },
		},

		-- 自动保存时格式化
		format_on_save = false,

		-- 允许同时使用多个格式化器，按顺序尝试
		retry_last = true,

		-- 打印调试信息
		log_level = vim.log.levels.ERROR,
	},
}
