local M = {}

local vue_script_languages = {
	javascript = true,
	javascriptreact = true,
	jsx = true,
	typescript = true,
	typescriptreact = true,
	tsx = true,
}

--[[
判断当前补全上下文是否位于 Vue 的 script 语言树中。
该函数用于过滤 Vue 文件里的 LSP 补全来源：script 区域只保留 vtsls，
template / style 等区域继续使用当前 buffer 的默认补全行为。

入参 ctx：blink.cmp 传入的补全上下文，包含 bufnr 和 cursor。
返回值：位于 script 区域时返回 "script"，位于其它区域时返回 "other"，
无法解析 Vue parser 时返回 nil。
]]
local function get_vue_block(ctx)
	if not ctx or vim.bo[ctx.bufnr].filetype ~= "vue" then
		return nil
	end

	local ok, parser = pcall(vim.treesitter.get_parser, ctx.bufnr, "vue")
	if not ok or not parser then
		return nil
	end

	local row = ctx.cursor[1] - 1
	local col = ctx.cursor[2]
	local ok_lang, lang_tree = pcall(parser.language_for_range, parser, { row, col, row, col })
	if not ok_lang or not lang_tree then
		return nil
	end

	if vue_script_languages[lang_tree:lang()] then
		return "script"
	end

	return "other"
end

--[[
构造 LuaSnip 的运行配置。
当前禁用历史记录，并保留移动、文本变化和进入插入模式时的片段区域检查，
避免离开片段区域后仍保留过期跳转状态。

返回值：可直接传给 luasnip.setup 的配置表。
]]
local function build_luasnip_options()
	return {
		history = false,
		region_check_events = "CursorMoved,CursorMovedI,InsertEnter",
		delete_check_events = "TextChanged,TextChangedI",
	}
end

--[[
注册离开插入模式时自动断开当前片段的 autocmd。
LuaSnip 在部分补全路径下会保留当前 buffer 的片段节点；离开插入模式时主动 unlink
可以避免下次 Tab 跳转进入旧片段状态。

入参 luasnip：已加载的 LuaSnip 模块。
返回值：本函数只注册 autocmd，不返回业务数据。
]]
local function register_luasnip_exit_autocmd(luasnip)
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = vim.api.nvim_create_augroup("LuaSnipExitOnInsertLeave", { clear = true }),
		callback = function()
			if luasnip.session and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] then
				luasnip.unlink_current()
			end
		end,
	})
end

--[[
加载本地 Lua 片段并扩展前端相关 filetype。
本仓库将通用 Web、TS 共享片段放在 lua/snippets 中；这里统一注册这些共享片段，
确保 TS、JS、React 和 Vue 文件能复用同一组模板。

入参 luasnip：已加载的 LuaSnip 模块。
返回值：本函数只加载片段和注册 filetype 映射，不返回业务数据。
]]
local function load_local_snippets(luasnip)
	require("luasnip.loaders.from_lua").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
	})
	luasnip.filetype_extend("typescript", { "web_shared", "ts_shared" })
	luasnip.filetype_extend("typescriptreact", { "web_shared", "ts_shared" })
	luasnip.filetype_extend("javascript", { "web_shared" })
	luasnip.filetype_extend("javascriptreact", { "web_shared" })
	luasnip.filetype_extend("vue", { "web_shared" })
end

--[[
返回 Vue script 区域的 vtsls trigger characters。
Vue buffer 中可能同时存在多个 LSP client；script 区域只使用 vtsls 的触发字符，
避免其它 client 的 template 补全触发符污染 TS/JS 补全。

入参 ctx：blink.cmp 当前补全上下文。
返回值：vtsls 暴露的 triggerCharacters；未找到时返回空表。
]]
local function get_vtsls_trigger_characters(ctx)
	local trigger_characters = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = ctx.bufnr })) do
		if client.name == "vtsls" then
			local completion_provider = client.server_capabilities.completionProvider
			if completion_provider and completion_provider.triggerCharacters then
				vim.list_extend(trigger_characters, completion_provider.triggerCharacters)
			end
		end
	end

	return trigger_characters
end

--[[
构造 blink.cmp 的完整配置。
配置覆盖 LuaSnip 展开、菜单展示、Vue script 补全过滤、CodeCompanion 补全源、
Skill 补全源、环境变量补全源和命令行补全。

返回值：可直接传给 blink.cmp.setup 的配置表。
]]
local function build_blink_options()
	return {
		fuzzy = { implementation = "prefer_rust_with_warning" },
		snippets = {
			preset = "luasnip",
			expand = function(snippet, _)
				return require("luasnip").lsp_expand(snippet)
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
					preselect = true,
					auto_insert = false,
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
			compat = {},
			default = { "lsp", "path", "snippets", "buffer" },
			min_keyword_length = 1,
			per_filetype = {
				codecompanion = { "codecompanion", "skills" },
				vue = { "lsp", "path", "snippets" },
			},
			providers = {
				lsp = {
					override = {
						get_trigger_characters = function(module)
							local ctx = {
								bufnr = vim.api.nvim_get_current_buf(),
								cursor = vim.api.nvim_win_get_cursor(0),
							}

							if get_vue_block(ctx) ~= "script" then
								return module:get_trigger_characters()
							end

							return get_vtsls_trigger_characters(ctx)
						end,
					},
					transform_items = function(ctx, items)
						if get_vue_block(ctx) ~= "script" then
							return items
						end

						return vim.tbl_filter(function(item)
							return item.client_name == "vtsls"
						end, items)
					end,
				},
				codecompanion = {
					name = "CodeCompanion",
					module = "codecompanion.providers.completion.blink",
					enabled = true,
				},
				skills = {
					name = "Skills",
					module = "tools.blink-skill-source",
					enabled = true,
					async = true,
					timeout_ms = 80,
					min_keyword_length = 0,
					score_offset = 12,
					opts = {
						skill_roots = {
							"~/.codex/skills",
							"~/.config/agents/skills",
						},
						allowed_filetypes = { "codecompanion" },
						include_system_skills = true,
						cache_ttl_ms = 30000,
						max_scan_depth = 3,
						max_items = 80,
					},
				},
				env = {
					name = "Env",
					module = "blink-cmp-env",
					kind = "Variable",
					opts = {
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
			["<A-m>"] = { "select_prev", "fallback" },
			["<A-n>"] = { "select_next", "fallback" },
			["<A-]>"] = { "scroll_documentation_down", "fallback" },
			["<A-[>"] = { "scroll_documentation_up", "fallback" },
		},
	}
end

--[[
将 compat source 写入 blink.cmp providers 和默认 source 列表。
该能力保留历史配置中的兼容入口；当前 compat 列表为空，但函数继续存在，
便于后续开启 nvim-cmp 兼容源时不需要改初始化流程。

入参 opts：blink.cmp 配置表，会被原地调整。
返回值：本函数只修改传入配置表，不返回业务数据。
]]
local function apply_compat_sources(opts)
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
end

--[[
为声明了 kind 的 provider 注册 blink.cmp 自定义补全类型。
当前 env provider 使用 Variable kind；注册后会把每个补全项的 kind 改成新增类型，
使菜单展示与普通 LSP kind 区分开。

入参 opts：blink.cmp 配置表，会被原地调整。
返回值：本函数只修改 provider 配置，不返回业务数据。
]]
local function apply_provider_kinds(opts)
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
				end
				return items
			end

			provider.kind = nil
		end
	end
end

--[[
初始化 LuaSnip 和本地片段。
该入口由 pack loader 在 blink.cmp 前调用，确保补全系统启动时 snippet preset
已经具备 LuaSnip 后端、jsregexp 支持和本地片段来源。

返回值：本函数只产生插件初始化副作用，不返回业务数据。
]]
function M.setup_luasnip()
	local luasnip = require("luasnip")
	luasnip.setup(build_luasnip_options())
	register_luasnip_exit_autocmd(luasnip)
	load_local_snippets(luasnip)
end

--[[
初始化 blink.cmp 补全系统。
关键流程：构造配置、展开 compat source、注册自定义 provider kind，
最后交给 blink.cmp.setup 完成补全、命令行和 provider 初始化。

返回值：本函数只产生插件初始化副作用，不返回业务数据。
]]
function M.setup()
	local opts = build_blink_options()
	apply_compat_sources(opts)
	apply_provider_kinds(opts)
	require("blink.cmp").setup(opts)
end

return M
