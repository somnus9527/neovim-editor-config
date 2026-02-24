local const = require("tools.const")

local M = {}

--- 是否存在 marker（支持字符串或 Lua 模式）
local function marker_exists(marker)
	local cwd = vim.fn.getcwd()
	local path = cwd .. "/" .. marker

	-- 先直接判断文件或目录是否存在
	if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
		return true
	end

	-- 支持模式匹配（pattern）
	local files = vim.fn.readdir(cwd)
	for _, file in ipairs(files) do
		if file:match(marker) then
			return true
		end
	end

	return false
end

-- 获取当前cwd的项目类型
function M.detect_project_type()
	for project_type, markers in pairs(const.project_markers) do
		for _, marker in ipairs(markers) do
			if marker_exists(marker) then
				return project_type
			end
		end
	end
	return "default"
end

--- 扩展设置keymap的opts
---@param opts
---@return
M.extend_opt = function(opts)
	local re_opt = {}
	if opts then
		re_opt = vim.tbl_deep_extend("force", const.default_keymap_opt, opts)
	end
	return re_opt
end

--- 设置快捷键
---@param keymaps
M.set_keymap = function(keymaps)
	local keymap = vim.keymap

	for _, value in pairs(keymaps) do
		keymap.set(value[1], value[2], value[3], M.extend_opt(value[4] or {}))
	end
end

--- 设置当前buffer的快捷键
---@param keymaps
M.set_buf_keymap = function(keymaps)
	local api = vim.api

	for _, value in pairs(keymaps) do
		api.nvim_buf_set_keymap(0, value[1], value[2], value[3], M.extend_opt(value[4] or {}))
	end
end

-- 监听lazyvim提供的VeryLazy事件，执行回调
M.on_very_lazy = function(fn)
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = fn,
	})
end

-- 按照路径创建嵌套表
M.ensure_path = function(tbl, path)
	local cur = tbl
	for i = 1, #path do
		local key = path[i]
		if cur[key] == nil then
			cur[key] = {}
		end
		cur = cur[key]
	end
	return cur
end

-- 是不是angular项目文件
M.angular_file_filter = function(filename)
	return filename:match("%.component%.ts$") or filename:match("%.component%.html$")
end

-- 获取光标或选中范围的行号
M.get_line_range = function()
	local mode = vim.fn.mode()
	if mode:find("[vV]") then
		local start_line = vim.fn.getpos("v")[2]
		local end_line = vim.fn.getpos(".")[2]
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
		return start_line, end_line
	else
		local line = vim.fn.line(".")
		return line, line
	end
end

-- 构造 git log 命令
M.git_log_range = function()
	local start_line, end_line = M.get_line_range()
	local file = vim.fn.expand("%")
	return string.format("git log -L %d,%d:%s", start_line, end_line, file)
end

-- 打开 fzf-lua 查看 git log
M.git_log_fzf = function()
	local fzf = require("fzf-lua")
	local cmd = M.git_log_range()

	fzf.fzf_exec(cmd, {
		prompt = "GitLog> ",
		previewer = "git show --color=always {+1}",
		actions = {
			["default"] = function(selected)
				local commit = selected[1]:match("^(%x+)")
				if commit then
					vim.cmd("tabnew | read !git show --color=always " .. commit)
				end
			end,
		},
	})
end

-- 获取root dir
M.root_dir = function()
	local lsp_util = require("lspconfig.util")
	local bufnr = vim.api.nvim_get_current_buf()
	local fname = vim.api.nvim_buf_get_name(bufnr)

	if fname == "" then
		return vim.loop.cwd()
	end

	local root_files = { "package.json", ".git", "angular.json", "vue.config.js" }
	local root = lsp_util.root_pattern(unpack(root_files))(fname)
	return root or vim.loop.cwd()
end

-- 获取相对路径
M.pretty_path = function()
	local root = M.root_dir()
	local file = vim.api.nvim_buf_get_name(0)
	if file:sub(1, #root) == root then
		file = "." .. file:sub(#root + 1)
	end
	return file
end

M.hex_to_rgb = function(hex)
	hex = hex:gsub("#", "")
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)
	return { r, g, b }
end

-- 获取颜色
M.color = function(group)
	local ok, hl = pcall(vim.api.nvim_get_hl_by_name, group, true)
	if not ok then
		return nil
	end
	if hl.foreground then
		return string.format("#%06x", hl.foreground)
	end
	return nil
end

M.switch_filetypes = function()
	local ok, fzf = pcall(require, "fzf-lua")
	local const = require("tools.const")
	if not ok then
		vim.notify("fzf-lua not found!", vim.log.levels.WARN)
		return
	end
	fzf.fzf_exec(const.switch_filetypes, {
		prompt = "Switch Filetype> ",
		actions = {
			["default"] = function(selected)
				if #selected > 0 then
					local ft = selected[1]
					vim.bo.filetype = ft
					vim.notify("Switched filetype to: " .. ft, vim.log.levels.INFO)
				end
			end,
		},
	})
end

-- 深度扩展，没有就创建
M.extend = function(t, key, values)
	local keys = vim.split(key, ".", { plain = true })
	for i = 1, #keys do
		local k = keys[i]
		t[k] = t[k] or {}
		if type(t) ~= "table" then
			return
		end
		t = t[k]
	end
	return vim.list_extend(t, values)
end

-- 获取pkg路径
M.get_pkg_path = function(pkg, path, opts)
	pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
	local root = vim.fn.stdpath("data") .. "/mason"
	opts = opts or {}
	opts.warn = opts.warn == nil and true or opts.warn
	path = path or ""
	local ret = vim.fs.normalize(root .. "/packages/" .. pkg .. "/" .. path)
	if opts.warn then
		vim.schedule(function()
			if not require("lazy.core.config").headless() and not vim.loop.fs_stat(ret) then
				M.warn(
					("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(
						pkg,
						path
					)
				)
			end
		end)
	end
	return ret
end

M.insert_tab = function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
end

M.get_project_root = function()
	local git_root = vim.fn.finddir(".git", ".;")
	if git_root ~= "" then
		return vim.fn.fnamemodify(git_root, ":h")
	end
	return vim.fn.getcwd()
end

M.get_poetry_python = function()
	local handle = io.popen("poetry env info -p 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		result = result:gsub("%s+", "")
		if result ~= "" then
			return result .. "/bin/python"
		end
	end
end

M.read_os_env = function(name)
	return os.getenv(name)
end

return M
