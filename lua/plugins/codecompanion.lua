--- 官网配置文档地址: https://codecompanion.olimorris.dev/
return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd", "CodeCompanionHistory" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Chat 历史会话保存扩展
		{
			"ravitemer/codecompanion-history.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
		},
	},
	opts = {
		display = {
			chat = {
				-- 随机选择经典诗句作为欢迎语
				intro_message = "路漫漫其修远兮，吾将上下而求索 ✨: ",
			},
			action_palette = {
				provider = "fzf_lua",
				opts = {
					show_preset_actions = true, -- Show the preset actions in the action palette?
					show_preset_prompts = true, -- Show the preset prompts in the action palette?
					title = "CodeCompanion actions", -- The title of the action palette
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
			},
		},
		interactions = {
			chat = {
				adapter = "kimi_cli",
				roles = {
					user = "SomnusZyy9527",
				},
				auto_scroll = true,
				opts = {
					completion_provider = "blink", -- blink|cmp|coc|default
					---Decorate the user message before it's sent to the LLM
					---@param message string
					---@param adapter CodeCompanion.Adapter
					---@param context table
					---@return string
					prompt_decorator = function(message, adapter, context)
						return string.format([[<prompt>%s</prompt>]], message)
					end,
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
						callback = function(chat)
							local package_json = vim.fn.getcwd() .. "/package.json"
							if vim.fn.filereadable(package_json) == 0 then
								vim.notify("未找到 package.json", vim.log.levels.WARN)
								return
							end

							local content = vim.fn.readfile(package_json)
							local ok, json = pcall(vim.json.decode, table.concat(content, "\n"))
							if not ok or not json.scripts then
								vim.notify("package.json 中没有 scripts", vim.log.levels.WARN)
								return
							end

							-- 构建脚本列表
							local scripts = {}
							for name, cmd in pairs(json.scripts) do
								table.insert(scripts, {
									name = name,
									cmd = cmd,
									display = string.format("%-20s %s", name, cmd),
								})
							end

							-- 按名称排序
							table.sort(scripts, function(a, b)
								return a.name < b.name
							end)

							-- 提取显示文本用于 fzf
							local displays = vim.tbl_map(function(s)
								return s.display
							end, scripts)

							-- 使用 fzf-lua 选择
							require("fzf-lua").fzf_exec(displays, {
								prompt = "选择 npm script> ",
								actions = {
									["default"] = function(selected, opts)
										if not selected or #selected == 0 then
											return
										end
										local selected_display = selected[1]
										-- 找到选中的脚本
										for _, script in ipairs(scripts) do
											if script.display == selected_display then
												-- 检测包管理器
												local pkg_manager = "npm"
												if vim.fn.filereadable(vim.fn.getcwd() .. "/pnpm-lock.yaml") == 1 then
													pkg_manager = "pnpm"
												elseif vim.fn.filereadable(vim.fn.getcwd() .. "/yarn.lock") == 1 then
													pkg_manager = "yarn"
												end

												local run_cmd = string.format("%s run %s", pkg_manager, script.name)
												local message = string.format(
													"请帮我执行这个命令并分析结果: `%s` (script: %s, command: %s)",
													run_cmd,
													script.name,
													script.cmd
												)

												-- 使用 vim.schedule 确保在 fzf 关闭后执行
												vim.schedule(function()
													local ok2, err = pcall(function()
														chat:add_message({
															role = "user",
															content = message,
														}, { visible = true })
														-- 提交消息触发 AI 响应
														if chat.submit then
															chat:submit()
														end
													end)
													if not ok2 then
														vim.notify(
															"添加消息失败: " .. tostring(err),
															vim.log.levels.ERROR
														)
													end
												end)
												break
											end
										end
									end,
								},
							})
						end,
					},
				},
				tools = {
					["grep_search"] = {
						---@param adapter CodeCompanion.HTTPAdapter
						---@return boolean
						enabled = function()
							return vim.fn.executable("rg") == 1
						end,
					},
					-- 自定义 Skill 示例
					["skill_creator"] = {
						-- 加载 skill 创建器的帮助文档
						callback = function()
							local skill_path = vim.fn.expand("~/.config/agents/skills/skill-creator/SKILL.md")
							if vim.fn.filereadable(skill_path) == 1 then
								local content = vim.fn.readfile(skill_path)
								return table.concat(content, "\n")
							end
							return "Skill creator 文档未找到"
						end,
						description = "加载 skill-creator 的帮助文档",
						opts = {
							require_approval_before = false,
						},
					},
					-- 加载指定 skill 的通用工具
					["load_skill"] = {
						callback = function(skill_name)
							local skill_file = vim.fn.expand("~/.config/agents/skills/" .. skill_name .. "/SKILL.md")
							if vim.fn.filereadable(skill_file) == 0 then
								return "Skill not found: " .. skill_name
							end
							local content = vim.fn.readfile(skill_file)
							return table.concat(content, "\n")
						end,
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
				adapter = "kimi_http",
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
				},
			},
			cmd = {
				adapter = "kimi_cli",
			},
			background = {
				adapter = "kimi_cli",
			},
		},
		prompt_library = {
			markdown = {
				dirs = {
					{
						path = "~/.config/agents/prompt_templates",
						files = "*.md",
					},
				},
			},
		},
		-- NOTE: The log_level is in `opts.opts`
		opts = {
			log_level = "ERROR",
			language = "Chinese",
		},
		extensions = {
			history = {
				enabled = true,
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
		{
			"<localLeader>.",
			"<CMD>CodeCompanionHistory<CR>",
			mode = { "n" },
			desc = "AI: Chat History",
		},
		{
			"<localLeader>a",
			"<CMD>CodeCompanionChat Add<CR>",
			mode = { "v" },
			desc = "AI: Add Selected Text to Chat",
		},
	},
}

