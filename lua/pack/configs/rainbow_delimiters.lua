local M = {}

--[[
判断当前缓冲区是否适合启用 rainbow-delimiters。
Neovim 0.12 下部分 UI buffer 或缺少 parser 的 filetype 会让插件拿到 nil parser，
因此这里提前过滤非普通文件、空 filetype 和无法创建 Treesitter parser 的缓冲区。

入参 bufnr：需要检查的缓冲区编号。
返回值：true 表示允许启用彩虹括号，false 表示跳过该缓冲区。
]]
local function can_enable_rainbow_delimiters(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return false
	end

	local filetype = vim.bo[bufnr].filetype
	if filetype == "" then
		return false
	end

	local lang = vim.treesitter.language.get_lang(filetype)
	if not lang then
		return false
	end

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
	return ok and parser ~= nil
end

--[[
配置 rainbow-delimiters 的启用条件、策略和高亮组。
该函数复用升级阶段加入的 parser 可用性判断，避免 UI buffer 触发运行时报错。

返回值：本函数只初始化插件配置，不返回业务数据。
]]
function M.setup()
	local rainbow_delimiters = require("rainbow-delimiters")
	local rainbow_delimiters_setup = require("rainbow-delimiters.setup")

	rainbow_delimiters_setup.setup({
		condition = can_enable_rainbow_delimiters,
		strategy = {
			[""] = rainbow_delimiters.strategy["global"],
			vim = rainbow_delimiters.strategy["local"],
		},
		query = {
			[""] = "rainbow-delimiters",
			lua = "rainbow-blocks",
		},
		priority = {
			[""] = 110,
			lua = 210,
		},
		highlight = {
			"rainbowdelimiterred",
			"rainbowdelimiteryellow",
			"rainbowdelimiterblue",
			"rainbowdelimiterorange",
			"rainbowdelimitergreen",
			"rainbowdelimiterviolet",
			"rainbowdelimitercyan",
		},
	})
end

return M
