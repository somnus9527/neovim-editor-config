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
	--[[
	为 Angular 模板文件优先启动 angular parser。
	如果 angular parser 启动失败，则降级尝试 html parser，避免模板文件完全失去高亮。
	]]
	callback = function()
		--[[
		延迟到读取完成后启动 Treesitter，确保 filetype 和缓冲区内容已经稳定。
		]]
		vim.schedule(function()
			local ok = pcall(vim.treesitter.start, 0, "angular")
			if not ok then
				pcall(vim.treesitter.start, 0, "html")
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

--[[
读取 Treesitter 节点文本。
该封装兼容节点不存在或解析失败的情况，避免日志插入功能影响正常编辑。

入参 node：需要读取文本的 Treesitter 节点。
入参 bufnr：节点所在缓冲区编号。
返回值：节点文本；读取失败时返回 nil。
]]
local function get_treesitter_node_text(node, bufnr)
	if not node then
		return nil
	end

	local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
	if ok then
		return text
	end

	return nil
end

--[[
读取指定字段的第一个 Treesitter 子节点。
该函数用于兼容不同语言 grammar 中 name/id 字段命名不一致的情况。

入参 node：需要读取字段的 Treesitter 节点。
入参 field_name：字段名称。
返回值：字段中的第一个节点；字段不存在时返回 nil。
]]
local function get_first_field_node(node, field_name)
	--[[
	保护性读取字段节点，避免不同 grammar 缺字段时影响调用方。
	]]
	local ok, field_nodes = pcall(function()
		return node:field(field_name)
	end)
	if ok and field_nodes then
		return field_nodes[1]
	end

	return nil
end

--[[
根据当前 Treesitter 节点向上推导可读的作用域路径。
路径优先使用函数调用、类、方法和具名节点字段，作为自动 console.log 的上下文提示。

入参 node：光标所在 Treesitter 节点。
入参 bufnr：节点所在缓冲区编号。
返回值：以点号拼接的作用域路径；无法推导时返回空字符串。
]]
local function get_console_log_scope_path(node, bufnr)
	local path = {}
	while node do
		local node_type = node:type()
		if node_type == "call_expression" then
			local function_node = node:child(0)
			if function_node and function_node:type() == "identifier" then
				local func_name = get_treesitter_node_text(function_node, bufnr)
				if func_name then
					table.insert(path, 1, func_name)
				end
			end
		else
			local name_node = get_first_field_node(node, "name") or get_first_field_node(node, "id")
			local name_text = get_treesitter_node_text(name_node, bufnr)
			if name_text then
				table.insert(path, 1, name_text)
			end
		end
		node = node:parent()
	end

	return table.concat(path, ".")
end

--[[
插入带文件路径、作用域和当前词的 console.log。
该函数依赖 Neovim 原生 Treesitter API 获取光标节点，失败时静默跳过。

返回值：本函数只向当前缓冲区插入日志语句，不返回业务数据。
]]
local function insert_console_log_with_scope()
	local variable = vim.fn.expand("<cword>")
	local file_path = vim.fn.expand("%:p")
	local relative_path = vim.fn.fnamemodify(file_path, ":~:.")
	local icon = "🚀"
	local tag = "[Neovim AutoGR Log]"
	local bufnr = vim.api.nvim_get_current_buf()

	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
	if not ok or not node then
		return
	end

	local scope_path = get_console_log_scope_path(node, bufnr)
	if scope_path == "" then
		scope_path = "Global"
	end

	local log_statement = string.format(
		"console.log('%%c %s %s: path = %s, scope = %s, %s = ', 'color: orangered; font-weight: bold;', %s);",
		icon,
		tag,
		relative_path,
		scope_path,
		variable,
		variable
	)

	vim.api.nvim_put({ log_statement }, "l", true, true)
end

-- 为 JavaScript、TypeScript 和相关文件添加自动插入日志的能力
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
	--[[
	在前端相关文件中注册一次 console.log 插入键位。
	键位使用闭包直接调用本文件的本地函数，避免暴露新的全局函数。
	]]
	callback = function()
		-- 绑定快捷键，仅在首次加载时
		if not vim.g.console_log_keymap_set then
			vim.keymap.set({ "n", "v" }, "<leader>ce", insert_console_log_with_scope, {
				desc = "插入带作用域的 console.log",
				silent = true,
			})
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

-- autocmd处理缩进，之前只有前端项目，我都是使用的2，但是现在有python，需要针对python项目改成4
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = function()
		local tools = require("tools.tools")
		local root = tools.get_project_root()

		-- 1️⃣ 如果项目有 .editorconfig，什么都不做
		if vim.fn.filereadable(root .. "/.editorconfig") == 1 then
			return
		end

		-- 2️⃣ 没有 editorconfig，判断是不是 Python 项目
		if vim.fn.filereadable(root .. "/pyproject.toml") == 1 then
			vim.bo.expandtab = true
			vim.bo.shiftwidth = 4
			vim.bo.tabstop = 4
			vim.bo.softtabstop = 4
		else
			vim.bo.expandtab = true
			vim.bo.shiftwidth = 2
			vim.bo.tabstop = 2
			vim.bo.softtabstop = 2
		end
	end,
})

vim.api.nvim_create_autocmd({
	"WinScrolled", -- or WinResized on NVIM-v0.9 and higher
	"BufWinEnter",
	"CursorHold",
	"InsertLeave",

	-- include this if you have set `show_modified` to `true`
	"BufModifiedSet",
}, {
	group = vim.api.nvim_create_augroup("barbecue.updater", {}),
	callback = function()
		local ok, barbecue_ui = pcall(require, "barbecue.ui")
		if ok then
			barbecue_ui.update()
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
	callback = function()
		vim.keymap.set("n", "<leader>gd", "<Plug>(jsdoc)", { buffer = true })
	end,
})
