--- 官网配置文档地址: https://codecompanion.olimorris.dev/
local tools = require("tools.tools")
local codex_settings = tools.read_codex_settings()
local codex_http_base_url = (codex_settings.base_url or "https://api.openai.com"):gsub("/+$", "")
local codex_responses_url = tools.build_codex_http_url(codex_http_base_url, codex_settings.wire_api)
local submit_when_normal_retries = math.max(0, math.floor(tonumber(codex_settings.submit_when_normal_retries) or 3))

return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
	version = '18.7.0',
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Chat 历史会话保存扩展
		-- {
		-- 	"ravitemer/codecompanion-history.nvim",
		-- 	dependencies = {
		-- 		"nvim-lua/plenary.nvim",
		-- 	},
		-- },
	},
	opts = {
		display = {
			chat = {
				-- 随机选择经典诗句作为欢迎语
				intro_message = "岂不闻，光阴如骏马加鞭，日月如落花流水 ✨: ",
			},
			action_palette = {
				provider = "fzf_lua",
				opts = {
					show_preset_actions = true, -- Show the preset actions in the action palette?
					show_preset_prompts = true, -- Show the preset prompts in the action palette?
					title = "CodeCompanion actions", -- The title of the action palette
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
		},
			rules = {
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
					-- 当前项目下的 .codecompanion/rules/*.md
					{
						path = vim.fn.getcwd() .. "/.config/agents/rules",
						files = "*.md",
					},
				},
			},
			-- monorepo 场景下，补充加载 git 仓库根目录的 AGENTS.md
			git_root_agents = {
				description = "AGENTS.md from git repository root",
				files = tools.get_git_root_agents_rule_files(),
			},
			opts = {
				chat = {
					autoload = { "default", "frontend_react", "git_root_agents" },
				},
			},
		},
		adapters = {
			http = {
        -- 专门用于https://deepl.micosoft.icu/api/codexusage/这个中转的配置,官方的还是用codex_http
				codex_responses = function()
					return require("codecompanion.adapters").extend("openai_responses", {
						name = "codex_responses",
						formatted_name = "Codex Responses",
						url = codex_responses_url,
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
				end,
				kimi_http = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						name = "kimi_http",

						schema = {
							model = {
								default = "kimi-k2.5", -- 改成你实际模型
							},
						},

						env = {
							url = "https://api.moonshot.cn",
							chat_url = "/v1/chat/completions",
							api_key = os.getenv("KIMI_API_KEY"),
						},
					})
				end,
				codex_http = function()
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
							url = codex_http_base_url,
							chat_url = "/v1/chat/completions",
							api_key = codex_settings.api_key or "OPENAI_API_KEY",
						},
					})
				end,
			},
			acp = {
				codex = function()
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
							auth_method = codex_settings.auth_method, -- "openai-api-key"|"codex-api-key"|"chatgpt"
						},
						env = {
							OPENAI_API_KEY = codex_settings.api_key or "OPENAI_API_KEY",
						},
					})
				end,
			},
		},
		interactions = {
			chat = {
				adapter = "codex",
				roles = {
					user = "SomnusZyy9527",
				},
				auto_scroll = true,
				opts = {
					completion_provider = "blink", -- blink|cmp|coc|default
					---Decorate the user message before it's sent to the LLM
					---@param message string
					---@return string
					-- prompt_decorator = function(message)
					-- 	return string.format([[<prompt>%s</prompt>]], message)
					-- end,
				},
				slash_commands = {
					["rules"] = {
						description = "使用 fzf-lua 选择并加载 rules",
						callback = tools.codecompanion_select_rules,
					},
					["file"] = {
						opts = {
							provider = "fzf_lua", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
						},
					},
					-- 添加 npm scripts 命令选择
					["command"] = {
						description = "运行 npm/yarn/pnpm 脚本",
						callback = tools.codecompanion_select_npm_script,
					},
					["quickfix"] = {
						description = "选择 buffer 并同步其诊断到 quickfix 后插入",
						callback = function(chat)
							local selectable_buffers = {}
							for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
									local name = vim.api.nvim_buf_get_name(bufnr)
									if name ~= "" then
										table.insert(selectable_buffers, {
											bufnr = bufnr,
											name = vim.fn.fnamemodify(name, ":~:."),
										})
									end
								end
							end

							if #selectable_buffers == 0 then
								vim.notify("没有可选的文件 buffer", vim.log.levels.WARN, {
									title = "CodeCompanion",
								})
								return
							end

							table.sort(selectable_buffers, function(a, b)
								return a.bufnr < b.bufnr
							end)

							local function sync_buffer_diagnostics_to_quickfix(item)
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

								local ok, quickfix = pcall(
									require,
									"codecompanion.interactions.chat.slash_commands.builtin.quickfix"
								)
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

							local current_bufnr = vim.api.nvim_get_current_buf()
							local current_item = nil
							for _, item in ipairs(selectable_buffers) do
								if item.bufnr == current_bufnr then
									current_item = item
									break
								end
							end

							if current_item and sync_buffer_diagnostics_to_quickfix(current_item) then
								return
							end

							if #selectable_buffers == 1 then
								sync_buffer_diagnostics_to_quickfix(selectable_buffers[1])
								return
							end

							vim.ui.select(selectable_buffers, {
								prompt = "选择要同步诊断的 buffer:",
								format_item = function(item)
									return string.format("[%d] %s", item.bufnr, item.name)
								end,
							}, sync_buffer_diagnostics_to_quickfix)
						end,
					},
				},
				tools = {
					["grep_search"] = {
						---@return boolean
						enabled = function()
							return vim.fn.executable("rg") == 1
						end,
					},
					-- 自定义 Skill 示例
					["skill_creator"] = {
						-- 加载 skill 创建器的帮助文档
						callback = tools.codecompanion_skill_creator_doc,
						description = "加载 skill-creator 的帮助文档",
						opts = {
							require_approval_before = false,
						},
					},
					-- 加载指定 skill 的通用工具
					["load_skill"] = {
						callback = tools.codecompanion_load_skill_doc,
						description = "加载指定 skill 的文档内容，参数: skill_name",
						opts = {
							require_approval_before = false,
						},
					},
				},
				keymaps = {
					send = {
						modes = { n = "<C-s>", i = "<C-s>" },
						callback = function(chat)
							local function submit_when_normal(retries)
								retries = retries or submit_when_normal_retries
								if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
									chat:submit()
									return
								end

								if retries <= 0 then
									chat:submit()
									return
								end

								vim.defer_fn(function()
									submit_when_normal(retries - 1)
								end, 10)
							end

							if chat and chat.adapter and chat.adapter.type == "acp" then
								local connection = chat.acp_connection
								local is_connected = connection and connection.is_connected and connection:is_connected()
								if not is_connected then
									vim.notify("CodeCompanion 连接初始化中，请稍后重试", vim.log.levels.WARN, {
										title = "CodeCompanion",
									})
									return
								end
							end

							if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
								local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
								vim.api.nvim_feedkeys(esc, "n", false)
								submit_when_normal()
								return
							end

							chat:submit()
						end,
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
						modes = { n = "ga" }, -- Remember this as DiffAccept
					},
					reject_change = {
						modes = { n = "gr" }, -- Remember this as DiffReject
					},
					always_accept = {
						modes = { n = "gy" }, -- Remember this as DiffYolo
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
		},
		prompt_library = {
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
		},
		-- NOTE: The log_level is in `opts.opts`
		opts = {
			log_level = "DEBUG",
			language = "Chinese",
		},
		extensions = {
			history = {
				enabled = false,
				opts = {
					-- 在 chat buffer 中打开历史的快捷键 (默认: gh)
					keymap = "gh",
					-- 自动为新 chat 生成标题
					auto_generate_title = false,
					-- 退出并重新进入 neovim 时，打开 chat 自动加载上次会话
					continue_last_chat = false,
					-- 使用 `gx` 清除 chat 时是否从历史中删除
					delete_on_clearing_chat = false,
					-- 选择器界面 ("telescope", "fzf_lua" 或 "default")
					picker = "fzf_lua",
					-- 启用详细日志
					enable_logging = false,
					-- 保存 chat 的目录
					dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
				},
			},
		},
	},
	keys = {
		{
			"<localLeader>:",
			"<CMD>CodeCompanionActions<CR>",
			mode = { "n", "v" },
			desc = "AI: Actions",
		},
		{
			"<localLeader>,",
			"<CMD>CodeCompanionChat Toggle<CR>",
			mode = { "n", "v" },
			desc = "AI: Chat Toggle",
		},
		-- {
		-- 	"<localLeader>.",
		-- 	"<CMD>CodeCompanionHistory<CR>",
		-- 	mode = { "n" },
		-- 	desc = "AI: Chat History",
		-- },
		{
			"<localLeader>a",
			function()
				vim.cmd("CodeCompanionChat Add")

				local mode = vim.api.nvim_get_mode().mode
				if mode == "v" or mode == "V" or mode == "\22" then
					local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
					vim.api.nvim_feedkeys(esc, "n", false)
				end

				-- vim.schedule(function()
				-- 	local ok, codecompanion = pcall(require, "codecompanion")
				-- 	if ok and codecompanion then
				-- 		local chat = codecompanion.last_chat()
				-- 		if chat and chat.bufnr then
				-- 			codecompanion.restore(chat.bufnr)
				-- 			return
				-- 		end
				-- 	end
				--
				-- 	vim.cmd("CodeCompanionChat")
				-- end)
			end,
			mode = { "v" },
			desc = "AI: Add Selected Text to Chat",
		},
		{
			"<localLeader>l",
			":CodeCompanion ",
			mode = { "v" },
			desc = "AI: Inline Prompt with Selection",
		},
	},
}
