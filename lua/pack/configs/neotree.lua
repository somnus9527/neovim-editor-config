local M = {}

-- 返回 Neo-tree 当前节点对应的路径。
local function get_node_path(state)
	local node = state.tree:get_node()
	return node, node:get_id()
end

-- 使用 fzf-lua 在当前节点目录中执行 live grep。
local function grep_from_node(state)
	local node, path = get_node_path(state)
	if node.type == "directory" then
		require("fzf-lua").live_grep({ cwd = path })
	else
		require("fzf-lua").live_grep({ cwd = vim.fn.fnamemodify(path, ":h") })
	end
end

-- 使用 fzf-lua 在当前节点目录中搜索文件。
local function files_from_node(state)
	local node, path = get_node_path(state)
	if node.type == "directory" then
		require("fzf-lua").files({ cwd = path })
	else
		require("fzf-lua").files({ cwd = vim.fn.fnamemodify(path, ":h") })
	end
end

-- 将当前节点路径复制到系统剪贴板。
local function copy_node_path(state)
	local _, path = get_node_path(state)
	vim.fn.setreg("+", path, "c")
end

-- 使用系统默认应用打开当前节点路径。
local function open_node_with_system(state)
	require("tools.tools").open_system(state.tree:get_node().path)
end

-- 文件移动或重命名后输出事件数据，保留原配置中的调试观察行为。
local function on_move(data)
	print(vim.inspect(data))
end

-- lazygit 退出后刷新 Neo-tree 的 git_status 来源。
local function refresh_git_status_after_lazygit()
	if package.loaded["neo-tree.sources.git_status"] then
		require("neo-tree.sources.git_status").refresh()
	end
end

-- 构造 Neo-tree 完整配置，保留文件系统、buffer 和 git_status 三个来源。
local function build_options()
	local events = require("neo-tree.events")

	return {
		sources = { "filesystem", "buffers", "git_status" },
		open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
		close_if_last_window = true,
		filesystem = {
			bind_to_cwd = true,
			follow_current_file = { enabled = true },
			use_libuv_file_watcher = true,
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_hidden = false,
			},
		},
		window = {
			position = "left",
			width = 80,
			mappings = {
				["s"] = "none",
				["z"] = "none",
				["S"] = "none",
				["f"] = grep_from_node,
				["F"] = files_from_node,
				["l"] = "open",
				["h"] = "close_node",
				["<space>"] = "none",
				["Y"] = {
					copy_node_path,
					desc = "Copy Path to Clipboard",
				},
				["O"] = {
					open_node_with_system,
					desc = "Open with System Application",
				},
				["P"] = { "toggle_preview", config = { use_float = false } },
			},
			fuzzy_finder_mappings = {
				["<A-n>"] = "move_cursor_down",
				["<A-m>"] = "move_cursor_up",
			},
		},
		default_component_configs = {
			indent = {
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
			git_status = {
				symbols = {
					unstaged = "󰄱",
					staged = "󰱒",
				},
			},
		},
		event_handlers = {
			{ event = events.FILE_MOVED, handler = on_move },
			{ event = events.FILE_RENAMED, handler = on_move },
		},
	}
end

-- 返回切换工作目录 Neo-tree 的快捷键回调。
local function create_toggle_cwd_callback(load_neotree)
	-- 这个闭包是实际 keymap 回调，用于首次按键时加载 neo-tree 后再打开目录树。
	return function()
		if load_neotree() then
			require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
		end
	end
end

-- 返回目录参数启动时的 Neo-tree 加载回调。
local function create_directory_loader(load_neotree)
	-- 这个闭包用于覆盖 `nvim <directory>` 场景，只有目录参数才会加载 neo-tree。
	return function()
		if package.loaded["neo-tree"] then
			return
		end

		local stats = vim.uv.fs_stat(vim.fn.argv(0))
		if stats and stats.type == "directory" then
			load_neotree()
		end
	end
end

-- 初始化 Neo-tree，并注册 lazygit 退出后的 git 状态刷新逻辑。
function M.setup()
	require("neo-tree").setup(build_options())
	vim.api.nvim_create_autocmd("TermClose", {
		group = vim.api.nvim_create_augroup("UserPackNeotreeGitStatus", { clear = true }),
		pattern = "*lazygit",
		callback = refresh_git_status_after_lazygit,
	})
end

-- 注册 Neo-tree 全局快捷键，首次触发时由调用方负责加载插件。
function M.register_keys(load_neotree)
	vim.keymap.set("n", "<leader>e", create_toggle_cwd_callback(load_neotree), {
		desc = "Explorer NeoTree (cwd)",
		remap = true,
		silent = true,
	})
end

-- 注册目录参数启动入口，保持 `nvim <directory>` 打开文件树的行为。
function M.register_directory_loader(load_neotree)
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("UserPackNeotreeStartDirectory", { clear = true }),
		desc = "Start Neo-tree with directory in vim.pack branch",
		once = true,
		callback = create_directory_loader(load_neotree),
	})
end

return M
