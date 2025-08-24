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

-- 设置angular treesitter
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.component.html", "*.container.html" },
	callback = function()
		vim.treesitter.start(nil, "angular")
	end,
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
