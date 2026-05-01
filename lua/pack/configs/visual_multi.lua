local M = {}

-- 配置 vim-visual-multi 的多光标快捷键，保留当前 Ctrl 系列入口。
function M.setup()
	vim.g.VM_default_mappings = 0
	vim.g.VM_maps = {
		["Select All"] = "<C-m>",
		["Find Under"] = "<C-n>",
		["Find Subword Under"] = "<C-n>",
		["Add Cursor Down"] = "<C-j>",
		["Add Cursor Up"] = "<C-k>",
	}
end

return M
