--- 官网配置文档地址: https://codecompanion.olimorris.dev/
return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		display = {
			action_palette = {
				provider = "fzf_lua",
				opts = {
					show_preset_actions = true, -- Show the preset actions in the action palette?
					show_preset_prompts = true, -- Show the preset prompts in the action palette?
					title = "CodeCompanion actions", -- The title of the action palette
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
				},
				tools = {
					["grep_search"] = {
						---@param adapter CodeCompanion.HTTPAdapter
						---@return boolean
						enabled = function()
							return vim.fn.executable("rg") == 1
						end,
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
		-- NOTE: The log_level is in `opts.opts`
		opts = {
			log_level = "DEBUG",
			language = "Chinese",
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
			"<localLeader>a",
			"<CMD>CodeCompanionChat Add<CR>",
			mode = { "v" },
			desc = "AI: Add Selected Text to Chat",
		},
	},
}
