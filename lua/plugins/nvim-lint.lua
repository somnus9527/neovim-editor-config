return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufWritePost", "InsertLeave" },
	config = function()
		local lint = require("lint")
    local parser = require("lint.parser")

		-- 检查项目里是否存在 eslint 配置文件
		local function has_eslint_config()
			local config_files = {
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.json",
				".eslintrc.yaml",
				".eslintrc.yml",
				"eslint.config.js",
			}
			for _, f in ipairs(config_files) do
				if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. f) == 1 then
					return true
				end
			end
			return false
		end

		-- 覆盖 eslint_d 的 cmd，强制使用项目本地 eslint_d
		-- if has_eslint_config() then
		-- 	lint.linters.eslint_d.cmd = vim.fn.getcwd()
		-- end

		-- 定义自定义 linter
		lint.linters.ruff_poetry = {
			cmd = "poetry",
			args = { "run", "ruff", "check", "--stdin-filename", "%" },
			stdin = true,
			stream = "stdout",
			parser = parser.from_errorformat("%f:%l:%c: %m", { source = "ruff" }),
		}

		lint.linters_by_ft = {
			javascript = has_eslint_config() and { "eslint" } or {},
			typescript = has_eslint_config() and { "eslint" } or {},
			javascriptreact = has_eslint_config() and { "eslint" } or {},
			typescriptreact = has_eslint_config() and { "eslint" } or {},
			svelte = has_eslint_config() and { "eslint_d" } or {},
			vue = has_eslint_config() and { "eslint" } or {},
			-- 效果不好，还是使用lsp中的jsonls
			-- json = { "jsonlint" },
			lua = { "luacheck" },
			c = { "clangtidy" },
			cpp = { "clangtidy" },
			python = { "ruff_poetry" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
