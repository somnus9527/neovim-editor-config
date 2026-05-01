local M = {}

-- 生成 bufferline 标签右侧的诊断摘要，保留错误和警告数量提示。
local function diagnostics_indicator(_, _, diag)
	local icons = require("tools.icons")
	local diagnostics_icons = icons.diagnostics
	local ret = (diag.error and diagnostics_icons.Error .. diag.error .. " " or "")
		.. (diag.warning and diagnostics_icons.Warn .. diag.warning or "")

	return vim.trim(ret)
end

-- 根据 buffer filetype 返回文件图标，确保无匹配时仍有默认图标。
local function get_element_icon(opts)
	local icon = require("nvim-web-devicons")

	return icon.get_icon_by_filetype(opts.filetype, { default = true })
end

-- 返回 bufferline 的完整配置，集中维护诊断、图标和侧边栏偏移。
local function build_options()
	return {
		options = {
			close_command = "bdelete! %d",
			right_mouse_command = "bdelete! %d",
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			diagnostics_indicator = diagnostics_indicator,
			offsets = {
				{
					filetype = "neo-tree",
					text = "Neo-tree",
					highlight = "Directory",
					text_align = "left",
				},
				{
					filetype = "snacks_layout_box",
				},
			},
			get_element_icon = get_element_icon,
		},
	}
end

-- 配置 bufferline，保持历史关闭命令、诊断标记和文件图标行为。
function M.setup()
	require("bufferline").setup(build_options())
end

-- 注册 bufferline 的切换、移动和关闭快捷键。
function M.register_keys()
	vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "切换Buffer固定", silent = true })
	vim.keymap.set("n", "<leader>bx", "<Cmd>BufferLineCloseOthers<CR>", { desc = "删除其它Buffer", silent = true })
	vim.keymap.set("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "删除右侧所有Buffer", silent = true })
	vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "删除左侧所有Buffer", silent = true })
	vim.keymap.set("n", "<A-TAB>", "<cmd>BufferLineCyclePrev<cr>", { desc = "上一个Buffer", silent = true })
	vim.keymap.set("n", "<TAB>", "<cmd>BufferLineCycleNext<cr>", { desc = "下一个Buffer", silent = true })
	vim.keymap.set("n", "<A-[>", "<cmd>BufferLineMovePrev<cr>", { desc = "当前Buffer往前移", silent = true })
	vim.keymap.set("n", "<A-]>", "<cmd>BufferLineMoveNext<cr>", { desc = "当前Buffer往后移", silent = true })
	vim.keymap.set("n", "-", "<cmd>bdelete<cr>", { desc = "删除当前Buffer", silent = true })
end

return M
