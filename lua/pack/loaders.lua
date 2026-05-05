local M = {}

local loaded_plugins = {}
local configured_plugins = {}

-- 按需加载 vim.pack 管理的 opt 插件，并避免重复 packadd。
local function load_pack_plugin(name)
	if loaded_plugins[name] then
		return true
	end

	local ok, err = pcall(vim.cmd.packadd, name)
	if not ok then
		vim.notify(("vim.pack 加载失败：%s\n%s"):format(name, err), vim.log.levels.ERROR)
		return false
	end

	loaded_plugins[name] = true
	return true
end

-- 断言指定 opt 插件已经通过 packadd 加载，便于在配置函数中中断失败路径。
local function packadd(name)
	if not load_pack_plugin(name) then
		error("vim.pack 插件加载失败：" .. name)
	end
end

-- 确保某个插件配置只执行一次，避免 autocmd 和按键入口重复初始化。
local function setup_once(name, callback)
	if configured_plugins[name] then
		return true
	end

	local ok, err = pcall(callback)
	if not ok then
		vim.notify(("vim.pack 配置失败：%s\n%s"):format(name, err), vim.log.levels.ERROR)
		return false
	end

	configured_plugins[name] = true
	return true
end

--[[
注册只执行一次的自动命令，用于维护事件触发的按需加载入口。
]]
local function once_autocmd(events, callback)
	vim.api.nvim_create_autocmd(events, {
		group = vim.api.nvim_create_augroup("UserPackLoaders", { clear = false }),
		once = true,
		callback = callback,
	})
end

--[[
在 VimEnter 后执行回调，用于启动完成后的延迟加载任务。
]]
local function on_startup(callback)
	if vim.v.vim_did_enter == 1 then
		vim.schedule(callback)
		return
	end

	once_autocmd("VimEnter", function()
		vim.schedule(callback)
	end)
end

-- 根据用户传入的命令参数，重新执行插件真实命令。
local function replay_command(command_name, opts)
	local range_prefix = ""
	if opts.range and opts.range > 0 then
		if opts.line1 == opts.line2 then
			range_prefix = tostring(opts.line1)
		else
			range_prefix = ("%d,%d"):format(opts.line1, opts.line2)
		end
	end

	local command_line = range_prefix .. command_name .. (opts.bang and "!" or "")
	if opts.args and opts.args ~= "" then
		command_line = command_line .. " " .. opts.args
	end
	if opts.mods and opts.mods ~= "" then
		command_line = opts.mods .. " " .. command_line
	end

	vim.cmd(command_line)
end

-- 删除迁移期占位命令，避免真实插件命令定义时发生同名冲突。
local function delete_proxy_commands(command_names)
	for _, command_name in ipairs(command_names) do
		pcall(vim.api.nvim_del_user_command, command_name)
	end
end

-- 注册命令占位入口，首次执行时加载插件并转发到真实命令。
local function proxy_commands(command_names, setup)
	for _, command_name in ipairs(command_names) do
		pcall(vim.api.nvim_create_user_command, command_name, function(opts)
			delete_proxy_commands(command_names)
			if setup() then
				replay_command(command_name, opts)
			end
		end, {
			bang = true,
			bar = true,
			nargs = "*",
			range = true,
		})
	end
end

--[[
配置 Tokyo Night 默认主题的透明背景。
该设置必须在 colorscheme 生效前执行，否则主题会先写入不透明的 Normal 背景。

返回值：配置成功返回 true；插件接口不可用时返回 false。
]]
local function setup_tokyonight_transparency()
	local ok, tokyonight = pcall(require, "tokyonight")
	if not ok then
		return false
	end

	tokyonight.setup({
		style = "storm",
		light_style = "day",
		transparent = true,
		terminal_colors = true,
		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
	})

	return true
end

-- 加载默认主题，并允许 Ghostty 的终端透明背景透出。
local function setup_colorscheme()
	if load_pack_plugin("tokyonight.nvim") then
		setup_tokyonight_transparency()
		pcall(vim.cmd.colorscheme, "tokyonight-storm")
	end
end

-- 加载备用主题插件，使 vim.pack 分支下仍可手动切换现有主题。
local function setup_optional_colorschemes()
	return setup_once("optional-colorschemes", function()
		packadd("gruvbox")
		packadd("tokyonight.nvim")
		packadd("evergarden")
		packadd("yoda.nvim")
		packadd("lush.nvim")
		packadd("zenbones.nvim")
		packadd("catppuccin")
		require("pack.configs.colorschemes").setup_optional()
	end)
end

-- 配置 Comment.nvim 和上下文注释逻辑，保持 TSX/Vue 等文件的注释语义。
local function setup_comment()
	if not load_pack_plugin("nvim-ts-context-commentstring") or not load_pack_plugin("Comment.nvim") then
		return
	end

	require("ts_context_commentstring").setup({
		enable = true,
		enable_autocmd = false,
	})

	require("Comment").setup({
		padding = true,
		sticky = true,
		ignore = nil,
		toggler = {
			line = "gcc",
			block = "gvc",
		},
		opleader = {
			line = "gc",
			block = "gv",
		},
		extra = {
			above = "gcO",
			below = "gco",
			eol = "gcA",
		},
		mappings = {
			basic = true,
			extra = true,
		},
		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		post_hook = nil,
	})
end

-- 配置 nvim-surround，提供成对符号增删改能力。
local function setup_surround()
	if load_pack_plugin("nvim-surround") then
		require("nvim-surround").setup()
	end
end

-- 配置 mini.pairs，保持插入模式和命令行模式的自动配对行为。
local function setup_mini_pairs()
	if not load_pack_plugin("mini.pairs") then
		return
	end

	require("mini.pairs").setup({
		modes = { insert = true, command = true, terminal = true },
		skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
		skip_ts = { "string" },
		skip_unbalanced = true,
		markdown = true,
		mappings = {
			["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
			["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
			["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
			[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
			["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
			["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
			['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
			["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
			["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
		},
	})
end

-- 配置 better-escape，避免 jk 映射在插入模式产生明显等待。
local function setup_better_escape()
	if load_pack_plugin("better-escape.nvim") then
		require("better_escape").setup()
	end
end

-- 配置 nvim-web-devicons，提供文件图标和本地定制图标。
local function setup_devicons()
	return setup_once("nvim-web-devicons", function()
		packadd("nvim-web-devicons")
		require("pack.configs.devicons").setup()
	end)
end

-- 配置 noice.nvim 与 nvim-notify，保留当前较保守的消息接管策略。
local function setup_noice()
	return setup_once("noice.nvim", function()
		packadd("nui.nvim")
		packadd("nvim-notify")
		packadd("noice.nvim")
		require("pack.configs.noice").setup()
	end)
end

--[[
配置 lualine，并保留启动期 statusline 行为。
]]
local function setup_lualine()
	return setup_once("lualine.nvim", function()
		packadd("lualine.nvim")
		require("pack.configs.lualine").setup()
	end)
end

-- 配置 bufferline，并确保图标依赖先加载。
local function setup_bufferline()
	return setup_once("bufferline.nvim", function()
		setup_devicons()
		packadd("bufferline.nvim")
		require("pack.configs.bufferline").setup()
	end)
end

-- 配置 incline 顶部文件信息栏。
local function setup_incline()
	return setup_once("incline.nvim", function()
		setup_devicons()
		packadd("incline.nvim")
		require("pack.configs.incline").setup()
	end)
end

-- 配置 barbecue 面包屑，并保持 navic 与图标依赖顺序。
local function setup_barbecue()
	return setup_once("barbecue", function()
		setup_devicons()
		packadd("nvim-navic")
		packadd("barbecue")
		require("pack.configs.barbecue").setup()
	end)
end

-- 配置 fidget LSP 进度与通知过滤。
local function setup_fidget()
	return setup_once("fidget.nvim", function()
		packadd("fidget.nvim")
		require("pack.configs.fidget").setup()
	end)
end

-- 配置窗口分隔线高亮插件。
local function setup_colorful_winsep()
	return setup_once("colorful-winsep.nvim", function()
		packadd("colorful-winsep.nvim")
		require("pack.configs.colorful_winsep").setup()
	end)
end

-- 配置滚动条插件，保留诊断标记和 UI buffer 排除策略。
local function setup_scrollbar()
	return setup_once("nvim-scrollbar", function()
		packadd("nvim-scrollbar")
		require("pack.configs.scrollbar").setup()
	end)
end

-- 配置颜色预览插件，保留 CSS、HSL、Tailwind 等显示能力。
local function setup_colorizer()
	return setup_once("nvim-colorizer.lua", function()
		packadd("nvim-colorizer.lua")
		require("pack.configs.colorizer").setup()
	end)
end

-- 配置 fzf-lua 搜索入口，并注册 vim.ui.select 适配。
local function setup_fzf()
	return setup_once("fzf-lua", function()
		if require("tools.tools").is_headless() then
			return
		end

			setup_devicons()
			packadd("fzf-lua")
			require("pack.configs.fzf").setup()
		end)
end

-- 配置 Spectre 全局搜索替换界面。
local function setup_spectre()
	return setup_once("nvim-spectre", function()
		packadd("plenary.nvim")
		setup_devicons()
		packadd("nvim-spectre")
		require("pack.configs.spectre").setup()
	end)
end

-- 配置 gitsigns，提供 Git 标记、行 blame 和 hunk 跳转。
local function setup_gitsigns()
	return setup_once("gitsigns.nvim", function()
		packadd("gitsigns.nvim")
		require("pack.configs.gitsigns").setup()
	end)
end

-- 配置 diffview，并保留冲突处理和文件面板快捷键。
local function setup_diffview()
	return setup_once("diffview.nvim", function()
		packadd("plenary.nvim")
		setup_devicons()
		packadd("diffview.nvim")
		require("pack.configs.diffview").setup()
	end)
end

-- 配置 git-log.nvim，保留当前行或选区日志入口。
local function setup_git_log()
	return setup_once("git-log.nvim", function()
		packadd("omega.nvim")
		packadd("git-log.nvim")
		require("pack.configs.git_log").setup()
	end)
end

-- 配置 blame-column.nvim，并提供命令占位懒加载。
local function setup_blame_column()
	return setup_once("blame-column.nvim", function()
		packadd("blame-column.nvim")
		require("pack.configs.blame_column").setup()
	end)
end

-- 配置 trouble.nvim 诊断与符号列表。
local function setup_trouble()
	return setup_once("trouble.nvim", function()
		packadd("trouble.nvim")
		require("pack.configs.trouble").setup()
	end)
end

-- 配置 todo-comments，并加载 FzfLua 集成所需依赖。
local function setup_todo_comments()
	return setup_once("todo-comments.nvim", function()
		packadd("plenary.nvim")
		setup_fzf()
		packadd("todo-comments.nvim")
		require("pack.configs.todo_comments").setup()
	end)
end

--[[
配置 Mason 与 mason-lspconfig，保留当前 v1 安装策略。
该函数先加载 Mason 本体，再加载 LSP 安装桥接插件，最后使用纯 pack 配置模块
设置 ensure_installed 与 automatic_installation。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_mason()
	return setup_once("mason.nvim", function()
		packadd("mason.nvim")
		require("pack.configs.mason").setup_mason()
		packadd("mason-lspconfig.nvim")
		require("pack.configs.mason").setup_lspconfig()
	end)
end

--[[
配置 Neovim 原生 LSP 入口。
关键流程：先确保 Mason 与 schema 依赖可用，再加载 nvim-lspconfig，最后执行
现有 config.lsp 中的 server、诊断和 LspAttach 键位配置。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_lsp()
	return setup_once("nvim-lspconfig", function()
		setup_mason()
		packadd("schemastore.nvim")
		packadd("nvim-navic")
		packadd("nvim-lspconfig")
		require("pack.configs.lsp").setup()
	end)
end

--[[
配置 LuaSnip 及本地片段加载。
该函数保留 jsregexp、InsertLeave 解绑和本地 snippets 加载逻辑，
为 blink.cmp 的 snippet preset 提供稳定后端。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_luasnip()
	return setup_once("LuaSnip", function()
		packadd("friendly-snippets")
		packadd("LuaSnip")
		require("pack.configs.blink").setup_luasnip()
	end)
end

--[[
将 blink.cmp 的 fuzzy 原生库目录提前放入 package.cpath。
pack 分支下多个 opt 插件的 lua/libs 目录可能同时出现在搜索路径中；这里显式把
blink 自身的 target/release 放到最前面，避免误加载 codesnap 的动态库。

返回值：本函数只调整 Lua C 模块搜索路径，不返回业务数据。
]]
local function prepend_blink_fuzzy_cpath()
	local extension = ".so"
	if jit.os:lower() == "osx" then
		extension = ".dylib"
	elseif jit.os:lower() == "windows" then
		extension = ".dll"
	end

	local release_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp/target/release"
	local cpath_prefix = ("%s/lib?%s;%s/?%s;"):format(release_dir, extension, release_dir, extension)
	if not package.cpath:find(release_dir, 1, true) then
		package.cpath = cpath_prefix .. package.cpath
	end
end

--[[
配置 blink.cmp 补全体系。
该函数按依赖顺序加载环境变量补全、LuaSnip 和 blink.cmp，再复用原配置中的
Vue script 补全过滤、CodeCompanion 补全源和自定义 skills 补全源。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_blink_cmp()
	return setup_once("blink.cmp", function()
		packadd("blink-cmp-env")
		setup_luasnip()
		packadd("blink.cmp")
		prepend_blink_fuzzy_cpath()
		require("pack.configs.blink").setup()
	end)
end

--[[
加载 blink.indent，保持普通文件打开后的缩进辅助能力。
该插件当前没有额外配置，packadd 后即可使用其默认初始化逻辑。

返回值：true 表示已加载或此前已加载，false 表示加载失败。
]]
local function setup_blink_indent()
	return setup_once("blink.indent", function()
		packadd("blink.indent")
	end)
end

--[[
配置 nvim-treesitter main 与 textobjects main。
该函数保留第二阶段迁移后的 parser 安装、FileType 启动、高亮、折叠、缩进和
textobjects select/move 配置，是第三阶段 pack 分支的 Treesitter 主入口。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_treesitter()
	return setup_once("nvim-treesitter", function()
		packadd("nvim-treesitter")
		packadd("nvim-treesitter-textobjects")
		require("pack.configs.treesitter").setup_textobjects()
		require("pack.configs.treesitter").setup()
	end)
end

--[[
配置 rainbow-delimiters 彩虹括号。
该插件依赖当前缓冲区可创建 Treesitter parser，因此加载前先确保 Treesitter 主入口
已经完成配置，并复用纯 pack 配置模块中的 UI buffer 过滤条件。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_rainbow_delimiters()
	return setup_once("rainbow-delimiters.nvim", function()
		setup_treesitter()
		packadd("rainbow-delimiters.nvim")
		require("pack.configs.rainbow_delimiters").setup()
	end)
end

--[[
配置 nvim-ts-autotag 自动闭合和重命名标签能力。
该函数在插入模式首次进入时加载，避免普通启动阶段提前处理无关 DOM 文件逻辑。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_ts_autotag()
	return setup_once("nvim-ts-autotag", function()
		setup_treesitter()
		packadd("nvim-ts-autotag")
		require("pack.configs.ts_autotag").setup()
	end)
end

--[[
配置 JSX 元素 textobject。
该函数加载 jsx-element.nvim 及新版 nvim-treesitter-textobjects，并注册 TSX/JSX
buffer 局部 it/at、]t/[t 键位。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_jsx_element()
	return setup_once("jsx-element.nvim", function()
		setup_treesitter()
		packadd("jsx-element.nvim")
		require("pack.configs.jsx_element").setup()
	end)
end

--[[
配置 flash.nvim 跳转插件。
ss/sS 键位会在第三批入口提前注册，这里只负责在普通文件读取时加载
插件本体，使键位回调中的 require("flash") 可以正常执行。

返回值：true 表示已加载或此前已加载，false 表示加载失败。
]]
local function setup_flash()
	return setup_once("flash.nvim", function()
		packadd("flash.nvim")
	end)
end

--[[
配置 neo-tree 文件树。
该函数按依赖顺序加载 plenary、nui、devicons 和 neo-tree，再应用纯 pack 文件树配置；
配置中的 fzf-lua 调用保持按用户交互时再执行。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_neotree()
	return setup_once("neo-tree.nvim", function()
		packadd("plenary.nvim")
		packadd("nui.nvim")
		setup_devicons()
		packadd("neo-tree.nvim")
		require("pack.configs.neotree").setup()
	end)
end

--[[
配置 conform.nvim 格式化器。
该函数只负责插件加载与 setup；实际格式化入口由第三批自定义键位和 ConformInfo
命令占位触发，避免未 packadd 时直接 require("conform")。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_conform()
	return setup_once("conform.nvim", function()
		packadd("conform.nvim")
		require("pack.configs.conform").setup()
	end)
end

--[[
配置 nvim-lint 并注册原有自动 lint 触发器。
该函数复用现有 eslint 配置探测、linters_by_ft 和 BufWritePost/InsertLeave 等触发逻辑。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_lint()
	return setup_once("nvim-lint", function()
		packadd("nvim-lint")
		require("pack.configs.lint").setup()
	end)
end

--[[
执行一次格式化，并在格式化结束后尝试触发 lint。
这是 conform.nvim lazy key 的 pack 分支等价实现，确保首次按键时先加载 conform，
并在 lint 已可用或可加载时同步执行 try_lint。

返回值：本函数通过插件副作用格式化当前 buffer，不返回业务数据。
]]
local function format_with_conform()
	if not setup_conform() then
		return
	end

	require("pack.configs.conform").format_with_lint(setup_lint)
end

--[[
配置 render-markdown.nvim。
Markdown 和 CodeCompanion buffer 首次出现时加载 mini.nvim、Treesitter 和渲染插件，
当前保持空配置以沿用插件默认渲染行为。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_render_markdown()
	return setup_once("render-markdown.nvim", function()
		setup_treesitter()
		packadd("mini.nvim")
		packadd("render-markdown.nvim")
		require("pack.configs.render_markdown").setup()
	end)
end

--[[
配置 CodeCompanion AI 交互插件。
该函数加载 plenary、Treesitter、fzf-lua、blink.cmp 和 CodeCompanion 本体，并应用
纯 pack 配置模块中的 OpenAI/Codex adapter、rules、slash command 和 prompt library。

返回值：true 表示配置已完成或此前已完成，false 表示加载或配置失败。
]]
local function setup_codecompanion()
	return setup_once("codecompanion.nvim", function()
		packadd("plenary.nvim")
		setup_treesitter()
		setup_fzf()
		setup_blink_cmp()
		packadd("codecompanion.nvim")
		require("pack.configs.codecompanion").setup()
	end)
end

-- 配置 mini.splitjoin，保留 <leader>q 的分割和合并切换入口。
local function setup_splitjoin()
	return setup_once("mini.splitjoin", function()
		packadd("mini.splitjoin")
		require("pack.configs.splitjoin").setup()
	end)
end

-- 加载 vim-cursorword，保持光标词高亮能力。
local function setup_cursorword()
	return setup_once("vim-cursorword", function()
		packadd("vim-cursorword")
	end)
end

-- 配置 vim-visual-multi，保留当前自定义多光标按键。
local function setup_visual_multi()
	return setup_once("vim-visual-multi", function()
		packadd("vim-visual-multi")
		require("pack.configs.visual_multi").setup()
	end)
end

-- 配置 neoscroll.nvim，保留 Alt+1/Alt+2 平滑滚动入口。
local function setup_neoscroll()
	return setup_once("neoscroll.nvim", function()
		packadd("neoscroll.nvim")
		require("pack.configs.neoscroll").setup()
	end)
end

-- 配置 toggleterm.nvim，保持终端窗口与 Alt 系列快捷键。
local function setup_toggleterm()
	return setup_once("toggleterm.nvim", function()
		packadd("toggleterm.nvim")
		require("pack.configs.toggleterm").setup()
	end)
end

-- 配置 bookmarks.nvim，保留 mm/ma/mn 等书签操作入口。
local function setup_bookmarks()
	return setup_once("bookmarks.nvim", function()
		packadd("bookmarks.nvim")
		require("pack.configs.bookmarks").setup()
	end)
end

-- 配置 convert.nvim，提供 CSS/SCSS 等样式文件中的单位转换能力。
local function setup_convert()
	return setup_once("convert.nvim", function()
		packadd("nui.nvim")
		packadd("convert.nvim")
		require("pack.configs.convert").setup()
	end)
end

-- 加载 json-to-types.nvim，提供 JSON 转 TypeScript 类型的命令入口。
local function setup_json_to_types()
	return setup_once("json-to-types.nvim", function()
		packadd("json-to-types.nvim")
	end)
end

-- 配置 copy_with_context.nvim，保留带文件上下文的复制入口。
local function setup_context_copy()
	return setup_once("copy_with_context.nvim", function()
		packadd("copy_with_context.nvim")
		require("pack.configs.context_copy").setup()
	end)
end

-- 配置 neogen，生成函数、类型和类注释模板。
local function setup_neogen()
	return setup_once("neogen", function()
		setup_luasnip()
		packadd("neogen")
		require("pack.configs.neogen").setup()
	end)
end

-- 配置 numb.nvim，保留跳转到行号前的预览窗口。
local function setup_numb()
	return setup_once("numb.nvim", function()
		packadd("numb.nvim")
		require("pack.configs.numb").setup()
	end)
end

-- 配置 lastplace.nvim，在重新打开文件时恢复历史光标位置。
local function setup_lastplace()
	return setup_once("lastplace.nvim", function()
		packadd("lastplace.nvim")
		require("pack.configs.lastplace").setup()
	end)
end

-- 配置 persistence.nvim，并让 session 快捷键首次使用时自动加载插件。
local function setup_persistence()
	return setup_once("persistence.nvim", function()
		packadd("persistence.nvim")
		require("pack.configs.persistence").setup()
	end)
end

-- 加载 visual-whitespace.nvim，显示选区中的空白字符。
local function setup_visual_whitespace()
	return setup_once("visual-whitespace.nvim", function()
		packadd("visual-whitespace.nvim")
	end)
end

-- 加载 emmet-vim，保留 HTML、Vue、CSS 与 JSX/TSX 的 Emmet 展开能力。
local function setup_emmet()
	return setup_once("emmet-vim", function()
		packadd("emmet-vim")
	end)
end

-- 配置 kulala.nvim，提供 http 文件中的请求发送与 cURL 辅助能力。
local function setup_kulala()
	return setup_once("kulala.nvim", function()
		packadd("kulala.nvim")
		require("pack.configs.kulala").setup()
	end)
end

-- 加载 codesnap.nvim，提供代码截图命令入口。
local function setup_codesnap()
	return setup_once("codesnap.nvim", function()
		packadd("codesnap.nvim")
	end)
end

-- 设置需要早于插件配置生效的全局开关。
local function setup_globals()
	vim.g.skip_ts_context_commentstring = true
	vim.g.skip_ts_context_commentstring_module = true
end

-- 注册第一批低复杂度插件的加载入口，后续继续扩展 cmd、keys、ft 等加载器。
local function setup_first_batch_loaders()
	setup_colorscheme()
	setup_surround()

	once_autocmd({ "BufNewFile", "BufReadPre" }, setup_comment)
	once_autocmd("InsertEnter", setup_mini_pairs)
	once_autocmd("InsertCharPre", setup_better_escape)
end

-- 执行第二批中等复杂度插件迁移，覆盖 UI、状态栏、搜索、Git 与诊断列表。
local function setup_second_batch_loaders()
	require("pack.configs.lualine").apply_startup_statusline()
	require("pack.configs.bufferline").register_keys()
	require("pack.configs.noice").register_keys(setup_noice)
	require("pack.configs.fzf").register_keys(setup_fzf)
	require("pack.configs.diffview").register_keys()
	require("pack.configs.trouble").register_keys(setup_trouble)

	proxy_commands({
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewFileHistory",
	}, setup_diffview)
	proxy_commands({ "BlameColumnToggle" }, setup_blame_column)

	on_startup(function()
		setup_devicons()
		setup_noice()
		setup_lualine()
		setup_bufferline()
		setup_incline()
		setup_fidget()
		setup_trouble()
		setup_fzf()
		setup_spectre()
		setup_colorizer()
	end)

	once_autocmd({ "BufNewFile", "BufReadPre" }, function()
		setup_barbecue()
		setup_gitsigns()
		setup_git_log()
		setup_todo_comments()
		setup_scrollbar()
	end)

	once_autocmd("WinLeave", setup_colorful_winsep)
end

--[[
执行核心编辑能力加载，覆盖 LSP、补全、Treesitter、文件树、格式化、lint、
Markdown 渲染和 CodeCompanion。
命令与按键入口会先注册占位加载器；文件类型和编辑事件按原有触发时机
加载对应插件，保持按需加载语义。

返回值：本函数只注册加载入口和必要的启动期配置，不返回业务数据。
]]
local function setup_third_batch_loaders()
	require("pack.configs.flash").register_keys(setup_flash)
	require("pack.configs.codecompanion").register_keys(setup_codecompanion)

	require("pack.configs.neotree").register_keys(setup_neotree)
	vim.keymap.set({ "n", "v" }, "<leader>f", format_with_conform, {
		desc = "格式化",
		silent = true,
	})

	setup_treesitter()
	require("pack.configs.neotree").register_directory_loader(setup_neotree)

	proxy_commands({ "Neotree" }, setup_neotree)
	proxy_commands({ "ConformInfo" }, setup_conform)
	proxy_commands({
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionCmd",
	}, setup_codecompanion)

	on_startup(function()
		setup_mason()
		setup_blink_cmp()
	end)

	once_autocmd({ "BufReadPre", "BufNewFile" }, function()
		setup_lsp()
		setup_rainbow_delimiters()
		setup_flash()
	end)

	once_autocmd("BufReadPost", setup_blink_indent)
	once_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, setup_lint)
	once_autocmd("InsertEnter", setup_ts_autotag)

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("UserPackThirdBatchFileType", { clear = true }),
		pattern = { "markdown", "codecompanion", "typescriptreact", "javascriptreact" },
		callback = function(event)
			if event.match == "markdown" or event.match == "codecompanion" then
				setup_render_markdown()
			end

			if event.match == "typescriptreact" or event.match == "javascriptreact" then
				setup_jsx_element()
			end
		end,
	})
end

--[[
执行第四批剩余插件迁移，覆盖工具类插件、语言辅助插件和低风险编辑增强。
这一批负责为 vim.pack 分支注册等价的事件、命令、文件类型和按键入口，
覆盖低风险工具类插件的原有按需加载语义。

返回值：本函数只注册加载入口，不返回业务数据。
]]
local function setup_fourth_batch_loaders()
	setup_lastplace()
	setup_toggleterm()
	require("pack.configs.persistence").register_keys(setup_persistence)
	require("pack.configs.convert").register_keys()
	require("pack.configs.json_to_types").register_keys()

	proxy_commands({
		"ConvertFindCurrent",
		"ConvertFindNext",
		"ConvertAll",
	}, setup_convert)
	proxy_commands({
		"ConvertJSONtoLang",
		"ConvertJSONtoLangBuffer",
	}, setup_json_to_types)
	proxy_commands({
		"CodeSnap",
		"CodeSnapHighlight",
	}, setup_codesnap)

	on_startup(function()
		setup_optional_colorschemes()
		setup_bookmarks()
	end)

	once_autocmd({ "BufNewFile", "BufReadPre" }, function()
		setup_splitjoin()
		setup_cursorword()
		setup_visual_multi()
		setup_neoscroll()
		setup_context_copy()
		setup_neogen()
		setup_numb()
		setup_persistence()
		setup_visual_whitespace()
	end)

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("UserPackFourthBatchFileType", { clear = true }),
		pattern = {
			"css",
			"less",
			"scss",
			"json",
			"html",
			"vue",
			"javascriptreact",
			"typescriptreact",
			"http",
		},
		callback = function(event)
			if event.match == "css" or event.match == "less" or event.match == "scss" then
				setup_convert()
			end

			if event.match == "json" then
				setup_json_to_types()
			end

			if
				event.match == "html"
				or event.match == "vue"
				or event.match == "css"
				or event.match == "javascriptreact"
				or event.match == "typescriptreact"
			then
				setup_emmet()
			end

			if event.match == "http" and setup_kulala() then
				require("pack.configs.kulala").register_keys({ buffer = event.buf })
			end
		end,
	})
end

-- 初始化 vim.pack 迁移期加载器，可通过 configure_plugins=false 只验证入口。
function M.setup(opts)
	opts = opts or {}
	setup_globals()

	if opts.configure_plugins == false then
		return
	end

	setup_first_batch_loaders()
	setup_second_batch_loaders()
	setup_third_batch_loaders()
	setup_fourth_batch_loaders()
end

return M
