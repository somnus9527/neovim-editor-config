return {
	"mhartington/formatter.nvim",
	lazy = true,
	module = true,
	config = function()
		local tools = require("tools.tools")
		local formatter = require("formatter")
		local util = require("formatter.util")
		local web_format = function()
			local is_eslint_project = tools.is_eslint_project()
			local is_prettier_project = tools.is_prettier_project()
			if is_eslint_project then
				return {
					exe = "eslint_d",
					args = { "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0), "--fix-to-stdout", try_node_modules = true },
					stdin = true,
				}
			elseif is_prettier_project then
				return {
					exe = "prettierd",
					args = { util.escape_path(util.get_current_buffer_file_path()) },
					stdin = true,
				}
			else
				return {
					exe = "tsfmt",
					args = {
						"--stdin",
						"--baseDir",
						util.escape_path(util.get_cwd()),
					},
					stdin = true,
					try_node_modules = true,
				}
			end
		end
		local opt = {
			logging = true,
			filetype = {
				typescriptreact = {
					web_format,
				},
				typescript = {
					web_format,
				},
				javascript = {
					web_format,
				},
				javascriptreact = {
					web_format,
				},
        vue = {
          web_format,
        },
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				json = {
					function()
						return {
							exe = "jq",
							args = {},
							stdin = true,
						}
					end,
				}
			},
		}
		formatter.setup(opt)
	end,
}
