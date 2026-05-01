local M = {}

-- 返回 Kulala HTTP 客户端配置，保留现有环境名和窗口标签。
local function get_options()
	return {
		default_env = "develop",
		global_keymaps = false,
		global_keymaps_prefix = "<leader>r",
		kulala_keymaps_prefix = "",
		ui = {
			show_variable_info_text = "float",
			default_winbar_panes = { "body", "headers", "verbose" },
			winbar_labels = {
				body = "Body",
				headers = "Headers",
				headers_body = "All",
				verbose = "Verbose",
				script_output = "Script Output",
				stats = "Stats",
				report = "Report",
				help = "Help",
			},
		},
	}
end

-- 调用 Kulala 模块中的指定动作，避免快捷键直接持有字符串命令。
local function run_action(action)
	require("kulala")[action]()
end

-- 注册 http buffer 局部 Kulala 快捷键。
function M.register_keys(opts)
	opts = opts or {}
	local keymaps = {
		{ "<leader>rb", "scratchpad", "打开请求草稿" },
		{ "<leader>rc", "copy", "复制为 cURL" },
		{ "<leader>rC", "from_curl", "从 cURL 粘贴请求" },
		{ "<leader>rg", "download_graphql_schema", "下载 GraphQL schema" },
		{ "<leader>ri", "inspect", "查看当前请求" },
		{ "<leader>rn", "jump_next", "跳到下一个请求" },
		{ "<leader>rp", "jump_prev", "跳到上一个请求" },
		{ "<leader>rq", "close", "关闭请求窗口" },
		{ "<leader>rr", "replay", "重放上次请求" },
		{ "<leader>rs", "run", "发送当前请求" },
		{ "<leader>rS", "show_stats", "显示请求统计" },
		{ "<leader>rt", "toggle_view", "切换请求视图" },
		{ "<leader>re", "set_selected_env", "选择请求环境" },
	}

	for _, keymap in ipairs(keymaps) do
		local action = keymap[2]
		vim.keymap.set("n", keymap[1], function()
			run_action(action)
		end, {
			buffer = opts.buffer,
			desc = keymap[3],
			silent = true,
		})
	end
end

-- 配置 kulala.nvim，关闭全局键位后由 pack loader 注册 http buffer 局部键位。
function M.setup()
	require("kulala").setup(get_options())
end

return M
