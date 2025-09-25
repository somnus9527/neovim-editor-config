return {
	"saghen/blink.cmp",
	version = "*",
	opts_extend = {
		"sources.completion.enabled_providers",
		"sources.compat",
		"sources.default",
	},
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
		},
		"rafamadriz/friendly-snippets",
		{
			"saghen/blink.compat",
			optional = true,
			opts = {},
			version = "*",
		},
	},
	event = "InsertEnter",

	opts = {
		snippets = {
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
			min_keyword_length = 0,
		},

		cmdline = {
			enabled = false,
		},

		keymap = {
			preset = "enter",
			["<A-y>"] = { "select_and_accept" },
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
			["<A-m>"] = { "select_prev", "fallback" },
			["<A-n>"] = { "select_next", "fallback" },
			["<A->>"] = { "scroll_documentation_down", "fallback" },
			["<A-<>"] = { "scroll_documentation_up", "fallback" },
			["<A-d>"] = { "show", "show_documentation", "hide_documentation" },
			-- ["<A-e>"] = { "hide", "fallback" },
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
