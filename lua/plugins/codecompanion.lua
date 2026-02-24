--- 官网配置文档地址: https://codecompanion.olimorris.dev/
return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
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
		interactions = {
			chat = {
				adapter = { name = "openai", model = "gpt-5.2-codex" },
				auto_scroll = true,
				opts = {
					completion_provider = "blink", -- blink|cmp|coc|default
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
				adapter = "codex",
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
				adapter = "codex",
			},
			background = {
				adapter = "codex",
			},
		},
		adapter = {
			http = {
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						schema = {
							model = {
								default = "gpt-5.2-codex", -- 👈 指定 OpenAI 的 GPT-5.2-Codex
							},
						},
						env = {
							api_key = vim.env.OPENAI_API_KEY,
						},
					})
				end,
			},
		},
		-- NOTE: The log_level is in `opts.opts`
		opts = {
			log_level = "DEBUG",
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
			"<C-,>",
			"<CMD>CodeCompanionChat Toggle<CR>",
			mode = { "i" },
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
