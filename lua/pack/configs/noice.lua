local M = {}

local noice_opts = {
	cmdline = {
		enabled = true,
	},
	messages = {
		enabled = false,
	},
	popupmenu = {
		enabled = false,
	},
	redirect = {
		enabled = false,
	},
	confirm = {
		enabled = false,
	},
	notify = {
		enabled = true,
		view = "notify",
	},
	lsp = {
		progress = {
			enabled = true,
		},
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
		hover = {
			enabled = true,
		},
		signature = {
			enabled = true,
		},
		message = {
			enabled = true,
		},
	},
	routes = {},
	presets = {
		bottom_search = false,
		command_palette = false,
		long_message_to_split = false,
		inc_rename = false,
		lsp_doc_border = true,
	},
	throttle = 1000 / 30,
	views = {},
}

local notify_opts = {
	background_colour = "#000000",
	fps = 60,
	icons = {
		DEBUG = "",
		ERROR = "",
		INFO = "",
		TRACE = "✎",
		WARN = "",
	},
	level = vim.log.levels.WARN,
	minimum_width = 30,
	render = "compact",
	stages = "slide",
	timeout = 3000,
	top_down = false,
}

-- 配置 noice.nvim 与 nvim-notify，保留当前低接管程度的消息策略。
function M.setup()
	require("noice").setup(noice_opts)
	require("notify").setup(notify_opts)
end

-- 返回执行指定 Noice 命令的 keymap 回调，首次触发时确保插件已加载。
local function create_noice_command_callback(load_noice, command)
	-- 这个闭包是实际 keymap 回调，用于按需加载 noice.nvim 后执行命令。
	return function()
		if load_noice() then
			vim.cmd(command)
		end
	end
end

-- 注册 Noice 消息查看和通知关闭快捷键。
function M.register_keys(load_noice)
	vim.keymap.set("n", "<localleader>nh", create_noice_command_callback(load_noice, "Noice history"), {
		desc = "显示消息历史 (Noice)",
		silent = true,
	})
	vim.keymap.set("n", "<localleader>nl", create_noice_command_callback(load_noice, "Noice last"), {
		desc = "显示最后消息 (Noice)",
		silent = true,
	})
	vim.keymap.set("n", "<localleader>nd", create_noice_command_callback(load_noice, "Noice dismiss"), {
		desc = "关闭通知 (Noice)",
		silent = true,
	})
	vim.keymap.set("n", "<localleader>ne", create_noice_command_callback(load_noice, "Noice errors"), {
		desc = "显示错误 (Noice)",
		silent = true,
	})
end

return M
