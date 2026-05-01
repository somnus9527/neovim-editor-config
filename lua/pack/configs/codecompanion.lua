local M = {}

local tools = require("tools.tools")

--[[
读取 CodeCompanion adapter 所需的 Codex 运行配置。
这里统一整理 base_url、responses URL、模型和提交重试次数，避免多个 adapter
各自读取 settings 后产生不一致的默认值。

返回值：包含 codex settings、HTTP base URL、Responses URL 和提交重试次数的上下文表。
]]
local function build_codex_context()
	local codex_settings = tools.read_codex_settings()
	local codex_http_base_url = (codex_settings.base_url or "https://api.openai.com"):gsub("/+$", "")

	return {
		settings = codex_settings,
		http_base_url = codex_http_base_url,
		responses_url = tools.build_codex_http_url(codex_http_base_url, codex_settings.wire_api),
		submit_when_normal_retries = math.max(0, math.floor(tonumber(codex_settings.submit_when_normal_retries) or 3)),
	}
end

--[[
构造 CodeCompanion rules 配置。
该配置把个人全局规则、前端/后端/移动端规则、当前项目规则和 git 根目录 AGENTS.md
暴露给 chat autoload 与手动 rules slash command 使用。

返回值：可直接传给 codecompanion.setup 的 rules 配置表。
]]
local function build_rules()
	return {
		core_global = {
			description = "个人全局协作与工程规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/core",
					files = "*.md",
				},
				"~/.claude/CLAUDE.md",
				"CLAUDE.md",
				"CLAUDE.local.md",
			},
		},
		frontend_architecture = {
			description = "前端架构与工程化规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/frontend",
					files = "architecture*.md",
				},
			},
		},
		frontend_react = {
			description = "React/TypeScript 开发规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/frontend",
					files = "react*.md",
				},
			},
		},
		node_service = {
			description = "Node.js 业务服务开发规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/node",
					files = "*.md",
				},
			},
		},
		python_tools = {
			description = "Python 工具脚本开发规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/python",
					files = "*.md",
				},
			},
		},
		flutter_app = {
			description = "Flutter App 开发规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/flutter",
					files = "*.md",
				},
			},
		},
		electron_client = {
			description = "Electron 桌面客户端规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/electron",
					files = "*.md",
				},
			},
		},
		infra_delivery = {
			description = "Docker/Compose/Nginx 与发布规则",
			parser = "codecompanion",
			files = {
				{
					path = "~/.config/agents/rules/infra",
					files = "*.md",
				},
			},
		},
		project_rules = {
			description = "Rule files for current project",
			parser = "codecompanion",
			files = {
				{
					path = vim.fn.getcwd() .. "/.config/agents/rules",
					files = "*.md",
				},
			},
		},
		git_root_agents = {
			description = "AGENTS.md from git repository root",
			files = tools.get_git_root_agents_rule_files(),
		},
		opts = {
			chat = {
				autoload = { "default", "frontend_react", "git_root_agents" },
			},
		},
	}
end

--[[
构造 Codex Responses HTTP adapter。
该 adapter 走 openai_responses 协议，并通过工具层清理网关不支持的参数、
解析 inline 响应，保持当前 Codex 中转服务的兼容行为。

入参 context：build_codex_context 返回的运行上下文。
返回值：CodeCompanion adapter 工厂函数。
]]
local function create_codex_responses_adapter(context)
	return function()
		local codex_settings = context.settings

		return require("codecompanion.adapters").extend("openai_responses", {
			name = "codex_responses",
			formatted_name = "Codex Responses",
			url = context.responses_url,
			schema = {
				model = {
					default = codex_settings.model,
					choices = {
						[codex_settings.model] = {
							formatted_name = "Codex (" .. codex_settings.model .. ")",
							opts = { has_function_calling = true, has_vision = true, can_reason = true },
						},
					},
				},
				["reasoning.effort"] = {
					default = codex_settings.reasoning_effort,
				},
			},
			parameters = {
				store = codex_settings.store,
				stream = true,
			},
			headers = {
				Accept = "text/event-stream",
			},
			handlers = {
				request = {
					build_parameters = function(_, params)
						return tools.sanitize_codex_response_parameters(params)
					end,
				},
				response = {
					parse_inline = function(_, data)
						return tools.parse_codex_inline_response(data)
					end,
				},
			},
			env = {
				api_key = codex_settings.api_key or "OPENAI_API_KEY",
			},
		})
	end
end

--[[
构造 Kimi 的 OpenAI 兼容 HTTP adapter。
该 adapter 只保留现有模型和 Moonshot API endpoint，供手动切换备用模型时使用。

返回值：CodeCompanion adapter 工厂函数。
]]
local function create_kimi_adapter()
	return function()
		return require("codecompanion.adapters").extend("openai_compatible", {
			name = "kimi_http",
			schema = {
				model = {
					default = "kimi-k2.5",
				},
			},
			env = {
				url = "https://api.moonshot.cn",
				chat_url = "/v1/chat/completions",
				api_key = os.getenv("KIMI_API_KEY"),
			},
		})
	end
end

--[[
构造 Codex OpenAI 兼容 HTTP adapter。
该 adapter 走 /v1/chat/completions，作为非 Responses 形态的 Codex HTTP 路径保留。

入参 context：build_codex_context 返回的运行上下文。
返回值：CodeCompanion adapter 工厂函数。
]]
local function create_codex_http_adapter(context)
	return function()
		local codex_settings = context.settings

		return require("codecompanion.adapters").extend("openai_compatible", {
			name = "codex_http",
			formatted_name = "Codex HTTP",
			schema = {
				model = {
					default = codex_settings.model,
					choices = {
						[codex_settings.model] = {
							formatted_name = "Codex (" .. codex_settings.model .. ")",
							opts = { has_function_calling = true, has_vision = true, can_reason = true },
						},
					},
				},
			},
			parameters = {
				store = codex_settings.store,
			},
			env = {
				url = context.http_base_url,
				chat_url = "/v1/chat/completions",
				api_key = codex_settings.api_key or "OPENAI_API_KEY",
			},
		})
	end
end

--[[
构造 Codex ACP adapter。
该 adapter 继续使用 codex-acp，并保留 on-request 审批和 read-only sandbox，
避免 CodeCompanion 会话绕过当前编辑器内的人工确认边界。

入参 context：build_codex_context 返回的运行上下文。
返回值：CodeCompanion adapter 工厂函数。
]]
local function create_codex_acp_adapter(context)
	return function()
		local codex_settings = context.settings

		return require("codecompanion.adapters").extend("codex", {
			commands = {
				default = {
					"codex-acp",
					"-c",
					'approval_policy="on-request"',
					"-c",
					'sandbox_mode="read-only"',
				},
			},
			defaults = {
				auth_method = codex_settings.auth_method,
			},
			env = {
				OPENAI_API_KEY = codex_settings.api_key or "OPENAI_API_KEY",
			},
		})
	end
end

--[[
构造 CodeCompanion adapters 配置。
这里集中注册 HTTP 和 ACP 两类 adapter，保持 chat 默认走 ACP、inline/cmd/background
继续走 codex_responses 的历史行为。

入参 context：build_codex_context 返回的运行上下文。
返回值：可直接传给 codecompanion.setup 的 adapters 配置表。
]]
local function build_adapters(context)
	return {
		http = {
			codex_responses = create_codex_responses_adapter(context),
			kimi_http = create_kimi_adapter(),
			codex_http = create_codex_http_adapter(context),
		},
		acp = {
			codex = create_codex_acp_adapter(context),
		},
	}
end

--[[
收集当前可同步诊断的普通文件 buffer。
quickfix slash command 只关心真实文件 buffer，过滤未加载、无文件名和特殊 buftype，
避免把终端、插件窗口或临时窗口暴露给诊断选择器。

返回值：按 bufnr 和相对路径组织的 buffer 条目列表。
]]
local function collect_file_buffers()
	local buffers = {}
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name ~= "" then
				table.insert(buffers, {
					bufnr = bufnr,
					name = vim.fn.fnamemodify(name, ":~:."),
				})
			end
		end
	end

	table.sort(buffers, function(left, right)
		return left.bufnr < right.bufnr
	end)

	return buffers
end

--[[
把指定 buffer 的诊断写入 quickfix 并插入到当前 CodeCompanion chat。
该函数先同步 quickfix，再调用内置 quickfix slash command，确保模型收到的是
CodeCompanion 原生格式化后的诊断上下文。

入参 chat：当前 CodeCompanion chat 对象。
入参 item：collect_file_buffers 生成的 buffer 条目。
返回值：成功同步并插入时返回 true，否则返回 false。
]]
local function sync_buffer_diagnostics_to_quickfix(chat, item)
	if not item then
		return false
	end

	local diagnostics = vim.diagnostic.get(item.bufnr)
	if #diagnostics == 0 then
		vim.notify("该 buffer 没有可用诊断", vim.log.levels.WARN, {
			title = "CodeCompanion",
		})
		return false
	end

	vim.fn.setqflist({}, " ", {
		title = "Diagnostics: " .. item.name,
		items = vim.diagnostic.toqflist(diagnostics),
	})

	local ok, quickfix = pcall(require, "codecompanion.interactions.chat.slash_commands.builtin.quickfix")
	if not ok then
		vim.notify("加载 CodeCompanion quickfix slash command 失败", vim.log.levels.ERROR, {
			title = "CodeCompanion",
		})
		return false
	end

	quickfix
		.new({
			Chat = chat,
			config = { opts = { contains_code = true } },
		})
		:execute()

	return true
end

--[[
返回 quickfix slash command 回调。
回调优先使用当前 buffer 诊断；当前 buffer 无诊断且有多个候选文件时，
再通过 vim.ui.select 让用户选择要同步的 buffer。

返回值：CodeCompanion slash command callback。
]]
local function create_quickfix_callback()
	return function(chat)
		local selectable_buffers = collect_file_buffers()
		if #selectable_buffers == 0 then
			vim.notify("没有可选的文件 buffer", vim.log.levels.WARN, {
				title = "CodeCompanion",
			})
			return
		end

		local current_bufnr = vim.api.nvim_get_current_buf()
		for _, item in ipairs(selectable_buffers) do
			if item.bufnr == current_bufnr and sync_buffer_diagnostics_to_quickfix(chat, item) then
				return
			end
		end

		if #selectable_buffers == 1 then
			sync_buffer_diagnostics_to_quickfix(chat, selectable_buffers[1])
			return
		end

		vim.ui.select(selectable_buffers, {
			prompt = "选择要同步诊断的 buffer:",
			format_item = function(item)
				return string.format("[%d] %s", item.bufnr, item.name)
			end,
		}, function(item)
			sync_buffer_diagnostics_to_quickfix(chat, item)
		end)
	end
end

--[[
构造 chat slash commands 配置。
该配置保留 rules、file、command 和自定义 quickfix 四类入口，其中 rules / command
复用工具层的 fzf 选择逻辑。

返回值：可直接传给 chat 配置的 slash_commands 表。
]]
local function build_slash_commands()
	return {
		["rules"] = {
			description = "使用 fzf-lua 选择并加载 rules",
			callback = tools.codecompanion_select_rules,
		},
		["file"] = {
			opts = {
				provider = "fzf_lua",
			},
		},
		["command"] = {
			description = "运行 npm/yarn/pnpm 脚本",
			callback = tools.codecompanion_select_npm_script,
		},
		["quickfix"] = {
			description = "选择 buffer 并同步其诊断到 quickfix 后插入",
			callback = create_quickfix_callback(),
		},
	}
end

--[[
构造 chat tools 配置。
这里保留 grep_search 可用性检查、skill_creator 文档加载和按名称加载 skill 文档的
自定义工具能力。

返回值：可直接传给 chat 配置的 tools 表。
]]
local function build_chat_tools()
	return {
		["grep_search"] = {
			enabled = function()
				return vim.fn.executable("rg") == 1
			end,
		},
		["skill_creator"] = {
			callback = tools.codecompanion_skill_creator_doc,
			description = "加载 skill-creator 的帮助文档",
			opts = {
				require_approval_before = false,
			},
		},
		["load_skill"] = {
			callback = tools.codecompanion_load_skill_doc,
			description = "加载指定 skill 的文档内容，参数: skill_name",
			opts = {
				require_approval_before = false,
			},
		},
	}
end

--[[
递归等待模式切回普通态后提交 chat。
从插入模式按 Ctrl-s 时，需要先发送 Esc 再提交；这里用短重试等待模式切换完成，
避免还在插入态时直接提交导致输入残留或按键被吞。

入参 chat：当前 CodeCompanion chat 对象。
入参 retries：剩余重试次数，耗尽后仍会提交。
返回值：本函数只触发 chat 提交副作用，不返回业务数据。
]]
local function submit_when_normal(chat, retries)
	if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
		chat:submit()
		return
	end

	if retries <= 0 then
		chat:submit()
		return
	end

	vim.defer_fn(function()
		submit_when_normal(chat, retries - 1)
	end, 10)
end

--[[
检查 ACP chat 连接是否已经可用。
ACP adapter 初始化存在短暂连接窗口，未连上时直接提交会失败；这里给出明确提示，
让用户稍后重试。

入参 chat：当前 CodeCompanion chat 对象。
返回值：连接可用或非 ACP adapter 时返回 true，否则返回 false。
]]
local function is_chat_ready(chat)
	if not (chat and chat.adapter and chat.adapter.type == "acp") then
		return true
	end

	local connection = chat.acp_connection
	local is_connected = connection and connection.is_connected and connection:is_connected()
	if is_connected then
		return true
	end

	vim.notify("CodeCompanion 连接初始化中，请稍后重试", vim.log.levels.WARN, {
		title = "CodeCompanion",
	})
	return false
end

--[[
创建 CodeCompanion chat 的发送回调。
该回调保留插入模式先退出再提交的历史行为，并在 ACP 连接未完成时阻止提交。

入参 context：build_codex_context 返回的运行上下文。
返回值：CodeCompanion chat keymap callback。
]]
local function create_chat_send_callback(context)
	return function(chat)
		if not is_chat_ready(chat) then
			return
		end

		if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
			local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
			vim.api.nvim_feedkeys(esc, "n", false)
			submit_when_normal(chat, context.submit_when_normal_retries)
			return
		end

		chat:submit()
	end
end

--[[
构造 CodeCompanion interactions 配置。
chat 默认走 Codex ACP，inline/cmd/background 继续走 codex_responses，同时保留
补全 provider、slash commands、tools 和 diff 接受/拒绝快捷键。

入参 context：build_codex_context 返回的运行上下文。
返回值：可直接传给 codecompanion.setup 的 interactions 配置表。
]]
local function build_interactions(context)
	return {
		chat = {
			adapter = "codex",
			roles = {
				user = "SomnusZyy9527",
			},
			auto_scroll = true,
			opts = {
				completion_provider = "blink",
			},
			slash_commands = build_slash_commands(),
			tools = build_chat_tools(),
			keymaps = {
				send = {
					modes = { n = "<C-s>", i = "<C-s>" },
					callback = create_chat_send_callback(context),
					opts = {},
				},
				close = {
					modes = { n = "<C-c>", i = "<C-c>" },
					opts = {},
				},
			},
		},
		inline = {
			adapter = "codex_responses",
			keymaps = {
				accept_change = {
					modes = { n = "ga" },
				},
				reject_change = {
					modes = { n = "gr" },
				},
				always_accept = {
					modes = { n = "gy" },
				},
				stop = {
					modes = { n = "q" },
				},
			},
		},
		cmd = {
			adapter = "codex_responses",
		},
		background = {
			adapter = "codex_responses",
		},
	}
end

--[[
构造 CodeCompanion 展示配置。
这里保留 fzf_lua action palette、split diff 和中文诗句欢迎语，匹配历史 lazy 配置。

返回值：可直接传给 codecompanion.setup 的 display 配置表。
]]
local function build_display()
	return {
		chat = {
			intro_message = "岂不闻，光阴如骏马加鞭，日月如落花流水 ✨: ",
		},
		action_palette = {
			provider = "fzf_lua",
			opts = {
				show_preset_actions = true,
				show_preset_prompts = true,
				title = "CodeCompanion actions",
			},
		},
		diff = {
			enabled = true,
			provider = "split",
			provider_opts = {
				split = {
					layout = "vertical",
				},
			},
		},
	}
end

--[[
构造 CodeCompanion prompt library 配置。
Markdown prompt 模板按业务域分目录加载，供 action palette 和 prompt library 复用。

返回值：可直接传给 codecompanion.setup 的 prompt_library 配置表。
]]
local function build_prompt_library()
	return {
		markdown = {
			dirs = {
				"~/.config/agents/prompt_templates/cross",
				"~/.config/agents/prompt_templates/frontend",
				"~/.config/agents/prompt_templates/node",
				"~/.config/agents/prompt_templates/python",
				"~/.config/agents/prompt_templates/flutter",
				"~/.config/agents/prompt_templates/electron",
				"~/.config/agents/prompt_templates/infra",
			},
		},
	}
end

--[[
构造 CodeCompanion 扩展配置。
history 扩展当前保持禁用，但保留原始选项，便于后续重新安装扩展后直接恢复。

返回值：可直接传给 codecompanion.setup 的 extensions 配置表。
]]
local function build_extensions()
	return {
		history = {
			enabled = false,
			opts = {
				keymap = "gh",
				auto_generate_title = false,
				continue_last_chat = false,
				delete_on_clearing_chat = false,
				picker = "fzf_lua",
				enable_logging = false,
				dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
			},
		},
	}
end

--[[
构造完整 CodeCompanion setup 配置。
该函数是配置聚合层：先读取 Codex 运行上下文，再组装 display、rules、adapters、
interactions、prompt library、日志语言和扩展配置。

返回值：可直接传给 require("codecompanion").setup 的配置表。
]]
local function build_options()
	local context = build_codex_context()

	return {
		display = build_display(),
		rules = build_rules(),
		adapters = build_adapters(context),
		interactions = build_interactions(context),
		prompt_library = build_prompt_library(),
		opts = {
			log_level = "DEBUG",
			language = "Chinese",
		},
		extensions = build_extensions(),
	}
end

--[[
执行 CodeCompanion 主配置。
该入口由 vim.pack loader 在首次命令或按键触发时调用，依赖插件已经在调用前 packadd。

返回值：本函数只产生插件初始化副作用，不返回业务数据。
]]
function M.setup()
	require("codecompanion").setup(build_options())
end

--[[
返回执行 CodeCompanion 命令的快捷键回调。
首次按键会先调用 loader 加载和配置插件，再执行目标命令，避免直接依赖 lazy.nvim
的 keys 懒加载行为。

入参 load_codecompanion：加载并配置 CodeCompanion 的回调函数。
入参 command：加载成功后要执行的 Ex 命令。
返回值：可传给 vim.keymap.set 的回调函数。
]]
local function create_command_callback(load_codecompanion, command)
	return function()
		if load_codecompanion() then
			vim.cmd(command)
		end
	end
end

--[[
返回把可视选区加入 chat 的快捷键回调。
该回调保持原有行为：先执行 CodeCompanionChat Add，再退出可视模式，避免选区状态残留。

入参 load_codecompanion：加载并配置 CodeCompanion 的回调函数。
返回值：可传给 vim.keymap.set 的回调函数。
]]
local function create_add_selection_callback(load_codecompanion)
	return function()
		if not load_codecompanion() then
			return
		end

		vim.cmd("CodeCompanionChat Add")

		local mode = vim.api.nvim_get_mode().mode
		if mode == "v" or mode == "V" or mode == "\22" then
			local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
			vim.api.nvim_feedkeys(esc, "n", false)
		end
	end
end

--[[
注册 CodeCompanion 全局快捷键。
命令型快捷键通过回调显式加载插件；可视模式 inline prompt 保留原来的命令行映射，
让用户在 :CodeCompanion 后继续输入提示词。

入参 load_codecompanion：加载并配置 CodeCompanion 的回调函数。
返回值：本函数只注册 keymap，不返回业务数据。
]]
function M.register_keys(load_codecompanion)
	vim.keymap.set({ "n", "v" }, "<localLeader>:", create_command_callback(load_codecompanion, "CodeCompanionActions"), {
		desc = "AI 操作面板",
		silent = true,
	})
	vim.keymap.set({ "n", "v" }, "<localLeader>,", create_command_callback(load_codecompanion, "CodeCompanionChat Toggle"), {
		desc = "AI 聊天开关",
		silent = true,
	})
	vim.keymap.set("v", "<localLeader>a", create_add_selection_callback(load_codecompanion), {
		desc = "AI 添加选区到聊天",
		silent = true,
	})
	vim.keymap.set("v", "<localLeader>l", ":CodeCompanion ", {
		desc = "AI 使用选区发起内联提示",
		silent = false,
	})
end

return M
