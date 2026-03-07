return {
	"saghen/blink.cmp",
	version = "*",
	opts_extend = {
		"sources.completion.enabled_providers",
		"sources.compat",
		"sources.default",
	},
	dependencies = {
		"bydlw98/blink-cmp-env",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			opts = {
				history = false,
				region_check_events = "CursorMoved,CursorMovedI,InsertEnter",
				delete_check_events = "TextChanged,TextChangedI",
			},
			config = function(_, opts)
				local ls = require("luasnip")
				ls.setup(opts)

				local group = vim.api.nvim_create_augroup("LuaSnipExitOnInsertLeave", { clear = true })
				vim.api.nvim_create_autocmd("InsertLeave", {
					group = group,
					callback = function()
						if ls.session and ls.session.current_nodes[vim.api.nvim_get_current_buf()] then
							ls.unlink_current()
						end
					end,
				})

				require("luasnip.loaders.from_lua").lazy_load({
					paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
				})
				ls.filetype_extend("typescript", { "web_shared", "ts_shared" })
				ls.filetype_extend("typescriptreact", { "web_shared", "ts_shared" })
				ls.filetype_extend("javascript", { "web_shared" })
				ls.filetype_extend("javascriptreact", { "web_shared" })
				ls.filetype_extend("vue", { "web_shared" })
			end,
		},
		"rafamadriz/friendly-snippets",
		{
			"saghen/blink.compat",
			optional = true,
			opts = {},
			version = "*",
		},
	},
	-- 和codesnap冲突，所以需要先加载blink, 后续如果能解决codesnap的冲突，可以切回
	event = "VimEnter",
	-- event = "InsertEnter",

	opts = {
		fuzzy = { implementation = "prefer_rust_with_warning" },
		snippets = {
			preset = "luasnip",
			expand = function(snippet, _)
				local luasnip = require("luasnip")
				return luasnip.lsp_expand(snippet)
			end,
		},
		appearance = {
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",
		},
		completion = {
			trigger = {
				show_on_keyword = true,
				show_on_trigger_character = true,
				show_on_insert_on_trigger_character = true,
			},
			list = {
				selection = {
					preselect = true, -- 自动预选
					auto_insert = false, -- 是否自动把预选的内容写入 buffer（一般设 false，防止光标一动就插进去）
				},
			},
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			ghost_text = {
				enabled = vim.g.ai_cmp,
			},
		},

		sources = {
			-- adding any nvim-cmp sources here will enable them
			-- with blink.compat
			compat = {},
			default = { "lsp", "path", "snippets", "buffer" },
			min_keyword_length = 1,
			per_filetype = {
				codecompanion = { "codecompanion" }, -- 直接加就行
			},
			providers = {
				codecompanion = {
					name = "CodeCompanion",
					module = "codecompanion.providers.completion.blink",
					enabled = true,
				},
				env = {
					name = "Env",
					module = "blink-cmp-env",
					kind = "Variable",
					opts = {
						-- item_kind = require("blink.cmp.types").CompletionItemKind.Variable,
						show_braces = false,
						show_documentation_window = true,
					},
				},
			},
		},

		cmdline = {
			enabled = true,
		},

		keymap = {
			preset = "enter",
			["<A-y>"] = { "select_and_accept" },
			-- INFO: 这边注释的原因是，目前nvim-lint 配置luasnip，tab的跳转有问题，简单理解就是snippet用的是luasnip进行expand,所以blink内部没有是否在snippet中的状态
			-- 所以这两个快捷键永远不会生效，所以直接注释，通过keymap的手动定义，判断luasnip状态来进行跳转
			-- ["<Tab>"] = { "snippet_forward", "fallback" },
			-- ["<S-Tab>"] = { "snippet_backward", "fallback" },
			["<A-m>"] = { "select_prev", "fallback" },
			["<A-n>"] = { "select_next", "fallback" },
			["<A-]>"] = { "scroll_documentation_down", "fallback" },
			["<A-[>"] = { "scroll_documentation_up", "fallback" },
			-- ["<A-d>"] = { "show", "show_documentation", "hide_documentation" },
			-- ["<A-h>"] = { "hide", "fallback" },
		},
	},
	config = function(_, opts)
		local enabled = opts.sources.default
		for _, source in ipairs(opts.sources.compat or {}) do
			opts.sources.providers[source] = vim.tbl_deep_extend(
				"force",
				{ name = source, module = "blink.compat.source" },
				opts.sources.providers[source] or {}
			)
			if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
				table.insert(enabled, source)
			end
		end

		opts.sources.compat = nil

		for _, provider in pairs(opts.sources.providers or {}) do
			if provider.kind then
				local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
				local kind_idx = #CompletionItemKind + 1

				CompletionItemKind[kind_idx] = provider.kind
				CompletionItemKind[provider.kind] = kind_idx

				local transform_items = provider.transform_items
				provider.transform_items = function(ctx, items)
					items = transform_items and transform_items(ctx, items) or items
					for _, item in ipairs(items) do
						item.kind = kind_idx or item.kind
						-- item.kind_icon = LazyVim.config.icons.kinds[item.kind_name] or item.kind_icon or nil
					end
					return items
				end

				provider.kind = nil
			end
		end

		require("blink.cmp").setup(opts)
	end,
}
