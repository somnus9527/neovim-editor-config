-- 配置server
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
	cssls = {
		filetypes = { "css", "scss", "less" },
		settings = {
			css = {
				validate = true,
				lint = {
					unknownAtRules = "ignore",
				},
			},
			scss = {
				validate = true,
				lint = {
					unknownAtRules = "ignore",
				},
			},
			less = {
				validate = true,
				lint = {
					unknownAtRules = "ignore",
				},
			},
		},
	},
	vtsls = {
		filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
		},
		settings = {
			complete_function_calls = true,
			vtsls = {
				enableMoveToFileCodeAction = true,
				autoUseWorkspaceTsdk = true,
				experimental = {
					maxInlayHintLength = 30,
					completion = {
						enableServerSideFuzzyMatch = true,
					},
				},
			},
			typescript = {
				updateImportsOnFileMove = { enabled = "always" },
				suggest = {
					completeFunctionCalls = true,
				},
				inlayHints = {
					enumMemberValues = { enabled = true },
					functionLikeReturnTypes = { enabled = true },
					parameterNames = { enabled = "literals" },
					parameterTypes = { enabled = true },
					propertyDeclarationTypes = { enabled = true },
					variableTypes = { enabled = false },
				},
			},
		},
	},
}

for server, config in pairs(servers) do
	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end

-- 配置server end
-- 配置diagnostic
local icons = require("tools.icons")
local diagnostic = {
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
			[vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
			[vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
			[vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
		},
	},
}
vim.diagnostic.config(diagnostic)
-- 配置diagnostic end
-- lsp相关快捷键配置
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
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
		-- map.set('n', '<leader>f', vim.lsp.buf.format, { desc = '格式化' })
		map.set("n", "K", vim.lsp.buf.hover, extend({ desc = "Hover展示代码说明" }))
		map.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", extend({ desc = "展示报错详情" }))

		-- 特定 vtsls 快捷键
		if client.name == "vtsls" then
			-- 在 vtsls 的 LspAttach 回调里
			map.set("n", "gd", function()
				local vtsClient = vim.lsp.get_client_by_id(ev.data.client_id)
				if not vtsClient then
					return
				end

				local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
				client.request("workspace/executeCommand", {
					command = "typescript.goToSourceDefinition",
					arguments = { params },
				}, function(err, result)
					if err then
						-- 检测是否因为 TS 版本太低
						if err.message and err.message:match("version") then
							vim.lsp.buf.definition()
						end
						return
					end

					-- 如果返回正常，走内置跳转逻辑
					if result then
						vim.lsp.util.jump_to_location(result[1], "utf-8", true)
					else
						vim.lsp.buf.definition()
					end
				end, 0)
			end, { buffer = ev.buf, desc = "跳转到源码实现 (带 fallback)" })
			map.set("n", "gr", function()
				client.request("workspace/executeCommand", {
					command = "typescript.findAllFileReferences",
					arguments = { vim.uri_from_bufnr(0) },
				})
			end, { buffer = ev.buf, desc = "文件级引用 (File References)" })
		end
	end,
})
-- lsp相关快捷键配置 end
