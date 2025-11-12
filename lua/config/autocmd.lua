-- 自动从磁盘同步文件
-- 如果在tmux中使用的neovim，需要手动在.tmux.conf文件中开启如下配置：
-- set -g focus-events on
-- 然后刷新tmux
-- tmux source-file ~/.tmux.conf
-- 没有就创建这个文件
-- touce ~/.tmux.conf
-- 该文件内容可参考README.md中的：.tmux.conf文件示例
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	pattern = "*",
	command = "checktime",
})

-- 在spectre替换窗口内添加q快捷键，用于快速退出窗口
vim.api.nvim_create_autocmd("FileType", {
	pattern = "spectre_panel",
	callback = function()
		-- 只对 spectre 的窗口生效
		vim.keymap.set("n", "q", function()
			vim.cmd("q") -- 或者 require("spectre").close()
		end, { buffer = true, desc = "退出 Spectre 窗口" })
	end,
})

-- 设置angular treesitter
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.component.html", "*.container.html" },
	callback = function()
		vim.schedule(function()
			local ok = pcall(vim.treesitter.start, nil, "angular")
			if not ok then
				vim.treesitter.start(nil, "html")
			end
		end)
	end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.component.html", "*.container.html" },
	command = "setfiletype html",
})

-- 自动关闭No Name Tab (只在多Tab时处理)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPre" }, {
	pattern = "*",
	callback = function()
		-- 获取所有列出的 buffer 信息
		local buffers = vim.fn.getbufinfo({ buflisted = 1 })

		-- 当有多个 buffer 时才进行清理
		if #buffers > 1 then
			for _, buf in ipairs(buffers) do
				-- 检查 buffer 是否无名并且内容为空
				if buf.name == "" and buf.linecount == 1 and vim.fn.getbufline(buf.bufnr, 1)[1] == "" then
					-- 删除该无名 buffer
					vim.cmd("silent! bdelete " .. buf.bufnr)
				end
			end
		end
	end,
})

-- 为前端相关语言优化keyword配置
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"html",
		"css",
		"vue",
		"json",
		"less",
		"scss",
	},
	callback = function()
		vim.opt_local.iskeyword:append("-")
		vim.opt_local.iskeyword:append("_")
	end,
})

-- 为 JavaScript、TypeScript 和相关文件添加自动插入日志的能力
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
	callback = function()
		-- 检查 Tree-sitter 是否已正确加载
		if not pcall(require, "nvim-treesitter") then
			return
		end
		local ts_utils = require("nvim-treesitter.ts_utils") -- 修正为 ts_utils

		-- 定义全局函数 insert_console_log_with_scope
		_G.insert_console_log_with_scope = function()
			local variable = vim.fn.expand("<cword>")
			local file_path = vim.fn.expand("%:p")
			local relative_path = vim.fn.fnamemodify(file_path, ":~:.")
			local icon = "🚀"
			local tag = "[Neovim AutoGR Log]"

			-- 获取当前的 Tree-sitter 节点
			local node = ts_utils.get_node_at_cursor()
			if not node then
				return
			end

			-- 优化作用域路径解析
			local function get_scope_path(node)
				local path = {}
				while node do
					local node_type = node:type()
					-- 检查是否是函数、方法或类等节点
					if node_type == "call_expression" then
						local function_node = node:child(0)
						if function_node and function_node:type() == "identifier" then
							local func_name = ts_utils.get_node_text(function_node)[1]
							table.insert(path, 1, func_name)
						end
					else
						local name_node = node:field("name")[1] or node:field("id")[1] -- 尝试多种字段名称
						if name_node then
							local name_text = ts_utils.get_node_text(name_node)[1]
							if name_text then
								table.insert(path, 1, name_text) -- 插入路径从最里层到最外层
							end
						end
					end
					node = node:parent()
				end
				return table.concat(path, ".")
			end
			local scope_path = get_scope_path(node)
			if scope_path == "" then
				scope_path = "Global"
			end

			-- 生成 console.log 语句
			local log_statement = string.format(
				"console.log('%%c %s %s: path = %s, scope = %s, %s = ', 'color: orangered; font-weight: bold;', %s);",
				icon,
				tag,
				relative_path,
				scope_path,
				variable,
				variable
			)

			-- 插入 log 语句
			vim.api.nvim_put({ log_statement }, "l", true, true)
		end

		-- 绑定快捷键，仅在首次加载时
		if not vim.g.console_log_keymap_set then
			vim.api.nvim_set_keymap(
				"n",
				"<leader>ce",
				":lua insert_console_log_with_scope()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"v",
				"<leader>ce",
				":lua insert_console_log_with_scope()<CR>",
				{ noremap = true, silent = true }
			)
			vim.g.console_log_keymap_set = true
		end
	end,
})

-- quickfix q关闭
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = event.buf, silent = true })
		vim.keymap.set("n", "<CR>", function()
			local lnum = vim.fn.line(".") -- 当前 quickfix 光标所在行
			vim.cmd("cc " .. lnum) -- 跳到对应的 quickfix 项
			vim.cmd("cclose") -- 关闭 quickfix 窗口
		end, { buffer = true })
	end,
})
