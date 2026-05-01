local M = {}

-- 调整 fzf-lua 默认按键，使预览滚动、退出和 quickfix 选择符合当前习惯。
local function configure_default_keymaps()
	local config = require("fzf-lua").config

	config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
	config.defaults.keymap.fzf["ctrl-f"] = "half-page-up"
	config.defaults.keymap.fzf["ctrl-b"] = "half-page-down"
	config.defaults.keymap.fzf["ctrl-x"] = "jump"
	config.defaults.keymap.fzf["ctrl-j"] = "preview-page-down"
	config.defaults.keymap.fzf["ctrl-k"] = "preview-page-up"
	config.defaults.keymap.fzf["alt-e"] = "abort"
	config.defaults.keymap.builtin["<C-j>"] = "preview-page-down"
	config.defaults.keymap.builtin["<C-k>"] = "preview-page-up"
	config.defaults.keymap.builtin["<A-e>"] = "abort"
end

-- 根据本机可用命令返回图片预览器参数，未安装时返回 nil 禁用图片预览。
local function find_image_previewer()
	for _, candidate in ipairs({
		{ cmd = "ueberzug", args = {} },
		{ cmd = "chafa", args = { "{file}", "--format=symbols" } },
		{ cmd = "viu", args = { "-b" } },
	}) do
		if vim.fn.executable(candidate.cmd) == 1 then
			return vim.list_extend({ candidate.cmd }, candidate.args)
		end
	end
end

-- 递归修正 default-title profile 的 prompt，保持所有 picker 标题样式一致。
local function fix_prompt_profile(profile)
	profile.prompt = profile.prompt ~= nil and " " or nil
	for _, value in pairs(profile) do
		if type(value) == "table" then
			fix_prompt_profile(value)
		end
	end

	return profile
end

-- 根据 picker 类型生成 vim.ui.select 的窗口参数，LSP code action 保留预览区。
local function build_ui_select_opts(fzf_opts, items)
	return vim.tbl_deep_extend("force", fzf_opts, {
		prompt = " ",
		winopts = {
			title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
			title_pos = "center",
		},
	}, fzf_opts.kind == "codeaction" and {
		winopts = {
			layout = "vertical",
			height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
			width = 0.9,
			preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
				layout = "vertical",
				vertical = "down:15,border-top",
				hidden = "hidden",
			} or {
				layout = "vertical",
				vertical = "down:15,border-top",
			},
		},
	} or {
		winopts = {
			width = 0.9,
			height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
		},
	})
end

-- 在 fzf 终端窗口中注册 Alt 导航键，解决终端模式下方向键距离过远的问题。
local function setup_fzf_window_keymaps()
	local tools = require("tools.tools")
	local keymap = {
		{ "t", "<A-n>", "<Down>", { desc = "下移一个选项" } },
		{ "t", "<A-m>", "<Up>", { desc = "上移一个选项" } },
	}

	tools.set_buf_keymap(keymap)
end

-- 返回 LSP symbol 的高亮组名称，让 fzf-lua 与 Trouble 图标高亮保持一致。
local function symbol_highlight(symbol)
	return "TroubleIcon" .. symbol
end

-- 返回 LSP symbol 的展示文本，统一转小写并追加制表符对齐。
local function symbol_format(symbol)
	return symbol:lower() .. "\t"
end

-- 构造 fzf-lua 完整配置，覆盖搜索、预览、LSP 和窗口行为。
local function build_options()
	local actions = require("fzf-lua").actions
	local image_previewer = find_image_previewer()

	return {
		"default-title",
		fzf_colors = true,
		fzf_opts = {
			["--no-scrollbar"] = true,
		},
		defaults = {
			formatter = "path.filename_first",
		},
		previewers = {
			builtin = {
				syntax = true,
				syntax_limit_l = 3000,
				syntax_limit_b = 1024 * 1024,
				limit_b = 1024 * 1024 * 10,
				treesitter = {
					enabled = true,
					disabled = {},
					context = { max_lines = 1, trim_scope = "inner" },
				},
				extensions = {
					["png"] = image_previewer,
					["jpg"] = image_previewer,
					["jpeg"] = image_previewer,
					["gif"] = image_previewer,
					["webp"] = image_previewer,
				},
				ueberzug_scaler = "fit_contain",
			},
		},
		ui_select = build_ui_select_opts,
		winopts = {
			width = 0.9,
			height = 0.9,
			row = 0.35,
			col = 0.5,
			preview = {
				scrollchars = { "┃", "" },
			},
			on_create = setup_fzf_window_keymaps,
		},
		files = {
			cwd_prompt = false,
			fd_opts = table.concat({
				"--type",
				"f",
				"--hidden",
				"--follow",
				"--exclude",
				"node_modules",
				"--exclude",
				".git",
				"--exclude",
				"dist",
				"--exclude",
				"build",
			}, " "),
			actions = {
				["alt-g"] = { actions.toggle_ignore },
				["alt-h"] = { actions.toggle_hidden },
			},
		},
		grep = {
			rg_opts = table.concat({
				"--column",
				"--line-number",
				"--no-heading",
				"--color=always",
				"--smart-case",
				"--max-columns=4096",
				"-e",
			}, " "),
			actions = {
				["alt-g"] = { actions.toggle_ignore },
				["alt-h"] = { actions.toggle_hidden },
			},
		},
		lsp = {
			symbols = {
				symbol_hl = symbol_highlight,
				symbol_fmt = symbol_format,
				child_prefix = false,
			},
			code_actions = {
				previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
			},
		},
	}
end

-- 合并 default-title profile，并交给 fzf-lua 完成初始化。
function M.setup()
	configure_default_keymaps()

	local opts = build_options()
	if opts[1] == "default-title" then
		opts = vim.tbl_deep_extend("force", fix_prompt_profile(require("fzf-lua.profiles.default-title")), opts)
		opts[1] = nil
	end

	require("fzf-lua").setup(opts)
	require("fzf-lua").register_ui_select({ silent = true })
end

-- 返回加载后执行指定 fzf-lua action 的 keymap 回调。
local function create_fzf_action_callback(load_fzf, action_name)
	-- 这个闭包是实际 keymap 回调，用于按需加载 fzf-lua 后再执行 picker。
	return function()
		if load_fzf() then
			require("fzf-lua")[action_name]()
		end
	end
end

-- 返回切换 filetype 的 keymap 回调，确保 tools.switch_filetypes 执行前 fzf-lua 已可用。
local function create_switch_filetype_callback(load_fzf)
	-- 这个闭包是实际 keymap 回调，用于复用工具层的 filetype 选择逻辑。
	return function()
		if load_fzf() then
			require("tools.tools").switch_filetypes()
		end
	end
end

-- 注册 fzf-lua 搜索、LSP、Git 和颜色主题入口快捷键。
function M.register_keys(load_fzf)
	vim.keymap.set("n", "<leader><space>", create_fzf_action_callback(load_fzf, "files"), {
		desc = "文件搜索(CWD)",
		silent = true,
	})
	vim.keymap.set("n", "<leader>.", create_fzf_action_callback(load_fzf, "live_grep"), {
		desc = "字符搜索(Root Dir)",
		silent = true,
	})
	vim.keymap.set("v", "<leader>.", create_fzf_action_callback(load_fzf, "grep_visual"), {
		desc = "字符搜索 (Root Dir)",
		silent = true,
	})
	vim.keymap.set("n", "<leader>,", create_fzf_action_callback(load_fzf, "resume"), {
		desc = "重打开",
		silent = true,
	})
	vim.keymap.set("n", "<leader>bb", create_fzf_action_callback(load_fzf, "buffers"), {
		desc = "打开Buffers",
		silent = true,
	})
	vim.keymap.set("n", "<leader>/", create_fzf_action_callback(load_fzf, "lgrep_curbuf"), {
		desc = "字符搜索(当前Buffer)",
		silent = true,
	})
	vim.keymap.set("n", "<leader>wf", create_fzf_action_callback(load_fzf, "grep_cword"), {
		desc = "WORD搜索(CWD)",
		silent = true,
	})
	vim.keymap.set("n", "<leader>gc", create_fzf_action_callback(load_fzf, "git_bcommits"), {
		desc = "Git Buffer Commits",
		silent = true,
	})
	vim.keymap.set("n", "<leader>gh", create_fzf_action_callback(load_fzf, "git_commits"), {
		desc = "Git Commits",
		silent = true,
	})
	vim.keymap.set({ "n", "v" }, "<leader>ca", create_fzf_action_callback(load_fzf, "lsp_code_actions"), {
		desc = "Lsp Code Actions",
		silent = true,
	})
	vim.keymap.set("n", "<leader>lr", create_fzf_action_callback(load_fzf, "lsp_references"), {
		desc = "Lsp References",
		silent = true,
	})
	vim.keymap.set("n", "<leader>ld", create_fzf_action_callback(load_fzf, "lsp_definitions"), {
		desc = "Lsp Definitions",
		silent = true,
	})
	vim.keymap.set("n", "<leader>li", create_fzf_action_callback(load_fzf, "lsp_implementations"), {
		desc = "Lsp Implementations",
		silent = true,
	})
	vim.keymap.set("n", "<leader>ls", create_fzf_action_callback(load_fzf, "lsp_document_symbols"), {
		desc = "Lsp Symbols",
		silent = true,
	})
	vim.keymap.set("n", "<leader>lj", create_fzf_action_callback(load_fzf, "lsp_incoming_calls"), {
		desc = "Lsp Incoming Calls",
		silent = true,
	})
	vim.keymap.set("n", "<leader>lk", create_fzf_action_callback(load_fzf, "lsp_outgoing_calls"), {
		desc = "Lsp Outgoing Calls",
		silent = true,
	})
	vim.keymap.set("n", "<leader>st", create_switch_filetype_callback(load_fzf), {
		desc = "切换文件类型",
		silent = true,
	})
	vim.keymap.set("n", "<leader>`", create_fzf_action_callback(load_fzf, "colorschemes"), {
		desc = "Colorschemes",
		silent = true,
	})
end

return M
