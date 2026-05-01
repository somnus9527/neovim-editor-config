local M = {}

local parser_languages = {
	"c",
	"cpp",
	"dart",
	"dockerfile",
	"gitignore",
	"go",
	"graphql",
	"ini",
	"jsdoc",
	"python",
	"javascript",
	"typescript",
	"tsx",
	"html",
	"angular",
	"css",
	"scss",
	"svelte",
	"xml",
	"json5",
	"vue",
	"lua",
	"bash",
	"yaml",
	"markdown",
	"toml",
	"http",
}

local disabled_indent_languages = {
	python = true,
}

--[[
判断缓冲区是否适合启用 Treesitter。
这里统一过滤 UI buffer、空 filetype 和大文件，避免新版 nvim-treesitter main
在不可解析缓冲区中触发启动报错。

入参 bufnr：需要检查的缓冲区编号。
返回值：true 表示应该跳过 Treesitter，false 表示允许继续启动。
]]
local function should_skip_treesitter(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return true
	end

	if vim.bo[bufnr].filetype == "" then
		return true
	end

	local file_path = vim.api.nvim_buf_get_name(bufnr)
	if file_path == "" then
		return false
	end

	local ok, stats = pcall(vim.uv.fs_stat, file_path)
	if not ok or not stats then
		return false
	end

	return stats.size > 500 * 1024
end

--[[
解析当前缓冲区 filetype 对应的 Treesitter 语言。
该函数只做 filetype 到 parser 语言名的映射，不负责验证 parser 是否已安装。

入参 bufnr：需要解析语言的缓冲区编号。
返回值：语言名；无法解析时返回 nil。
]]
local function get_buffer_language(bufnr)
	local filetype = vim.bo[bufnr].filetype
	if filetype == "" then
		return nil
	end

	return vim.treesitter.language.get_lang(filetype) or filetype
end

--[[
为已经成功启动 Treesitter 的缓冲区启用折叠和缩进。
折叠使用 Neovim 0.12 原生 foldexpr；缩进继续使用 nvim-treesitter main 提供的
indentexpr，并保留 Python 禁用缩进的历史策略。

入参 bufnr：需要应用局部选项的缓冲区编号。
返回值：本函数只设置 buffer/window 局部选项，不返回业务数据。
]]
local function apply_treesitter_buffer_options(bufnr)
	vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.wo[0][0].foldmethod = "expr"

	local language = get_buffer_language(bufnr)
	if language and not disabled_indent_languages[language] then
		vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

--[[
按新版 nvim-treesitter main 的方式启动当前缓冲区功能。
关键流程：先过滤不适合的缓冲区，再尝试启动原生高亮，成功后补充折叠和缩进配置。

入参 args：FileType autocmd 传入的事件参数，必须包含目标缓冲区编号。
返回值：本函数只产生编辑器局部配置副作用，不返回业务数据。
]]
local function start_treesitter_for_buffer(args)
	local bufnr = args.buf
	if should_skip_treesitter(bufnr) then
		return
	end

	local ok = pcall(vim.treesitter.start, bufnr)
	if ok then
		apply_treesitter_buffer_options(bufnr)
	end
end

--[[
配置 nvim-treesitter-textobjects main 的选择和跳转行为。
该配置保持参数、函数、类 textobject 的选择模式，以及 move 模块写入 jumplist 的行为。

返回值：本函数只初始化插件配置，不返回业务数据。
]]
function M.setup_textobjects()
	require("nvim-treesitter-textobjects").setup({
		select = {
			lookahead = true,
			selection_modes = {
				["@parameter.outer"] = "v",
				["@function.outer"] = "V",
				["@class.outer"] = "V",
			},
			include_surrounding_whitespace = false,
		},
		move = {
			set_jumps = true,
		},
	})
end

--[[
配置 nvim-treesitter main 的安装目录、parser 安装和 FileType 启动入口。
新版插件不再自动接管高亮启用，因此这里显式注册普通文件缓冲区的启动逻辑。

返回值：本函数只初始化 Treesitter 主插件和自动命令，不返回业务数据。
]]
function M.setup()
	local treesitter = require("nvim-treesitter")

	treesitter.setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})
	treesitter.install(parser_languages)

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
		callback = start_treesitter_for_buffer,
	})
end

return M
