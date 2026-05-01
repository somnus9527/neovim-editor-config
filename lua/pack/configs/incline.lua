local M = {}

-- 获取指定 buffer 的诊断数量标签，供 incline 顶部栏展示快速状态。
local function get_diagnostic_label(bufnr)
	local icons = {
		error = require("tools.icons").diagnostics.Error,
		warn = require("tools.icons").diagnostics.Warn,
		info = require("tools.icons").diagnostics.Info,
		hint = require("tools.icons").diagnostics.Hint,
	}
	local label = {}

	for severity, icon in pairs(icons) do
		local count = #vim.diagnostic.get(bufnr, {
			severity = vim.diagnostic.severity[string.upper(severity)],
		})
		if count > 0 then
			table.insert(label, { icon .. count .. " ", group = "DiagnosticSign" .. severity })
		end
	end

	if #label > 0 then
		table.insert(label, { "┊ " })
	end

	return label
end

-- 渲染 incline 顶部文件信息，包含诊断、文件图标、文件名和当前时间。
local function render(props)
	local devicons = require("nvim-web-devicons")
	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
	if filename == "" then
		filename = "[No Name]"
	end

	local ft_icon, ft_color = devicons.get_icon_color(filename)
	local result = {
		{ " " },
		{ get_diagnostic_label(props.buf) },
		{ (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
		{ filename .. " ", gui = vim.bo[props.buf].modified and "bold,italic" or "bold" },
		{ "┊ " },
		{ os.date("%H:%M"), guifg = "red" },
		{ "  " },
	}

	return result
end

-- 配置 incline.nvim，保留顶部文件名、诊断和时间展示。
function M.setup()
	require("incline").setup({
		window = {
			padding = 0,
			margin = { vertical = 0, horizontal = 0 },
		},
		render = render,
	})
end

return M
