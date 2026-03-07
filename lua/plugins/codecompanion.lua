--- 官网配置文档地址: https://codecompanion.olimorris.dev/
local tools = require("tools.tools")
local codex_settings = tools.read_codex_settings()
local codex_http_base_url = (codex_settings.base_url or "https://api.openai.com"):gsub("/+$", "")
local codex_responses_url = tools.build_codex_http_url(codex_http_base_url, codex_settings.wire_api)

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
			global_rules = {
				description = "Rules files for global.",
				files = {
					-- 全局规则目录
					{
						path = "~/.config/agents/rules",
						files = "*.md",
					},
					-- Mix with literal file paths
					"~/.claude/CLAUDE.md",
					"CLAUDE.md",
					"CLAUDE.local.md",
				},
			},
			project_rules = {
				description = "Rule files for current project",
				files = {
					-- 当前项目下的 .codecompanion/rules/*.md
					{
						path = vim.fn.getcwd() .. "/.config/agents/rules",
						files = "*.md",
					},
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
		-- prompt_library = {
		-- 	markdown = {
		-- 		dirs = {
		-- 			{
		-- 				path = "~/.config/agents/prompt_templates",
		-- 				files = "*.md",
		-- 			},
		-- 		},
		-- 	},
		-- },
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
			"<CMD>CodeCompanionChat Add<CR>",
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
