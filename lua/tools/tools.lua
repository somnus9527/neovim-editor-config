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

M.get_git_root_agents_rule_files = function()
	local cwd = vim.fs.normalize(vim.fn.getcwd())
	local git_root = vim.fs.normalize(M.get_project_root())

	if git_root == "" or git_root == cwd then
		return {}
	end

	local agents_file = git_root .. "/AGENTS.md"
	if vim.fn.filereadable(agents_file) == 1 then
		return { agents_file }
	end

	return {}
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

local function trim_slash(value)
	return (value or ""):gsub("/+$", "")
end

local function map_codex_auth_method(value)
	if value == "chatgpt" then
		return "chatgpt"
	end
	if value == "codex-api-key" or value == "codex_api_key" then
		return "codex-api-key"
	end
	return "openai-api-key"
end

M.read_codex_settings = function()
	local config_path = vim.fn.expand("~/.codex/config.toml")
	local auth_path = vim.fn.expand("~/.codex/auth.json")

	local settings = {
		model = "gpt-5-codex",
		reasoning_effort = "high",
		store = false,
		auth_method = "openai-api-key",
		base_url = "https://api.openai.com",
		wire_api = "responses",
		submit_when_normal_retries = 3,
		api_key = nil,
	}

	if vim.fn.filereadable(config_path) == 1 then
		local lines = vim.fn.readfile(config_path)
		local provider_name
		local current_provider
		for _, line in ipairs(lines) do
			local line_content = vim.trim(line)
			if line_content ~= "" and not line_content:match("^#") then
				local section = line_content:match("^%[model_providers%.([%w_%-]+)%]$")
				if section then
					current_provider = section
				else
					local key, value = line_content:match('^([%w_]+)%s*=%s*"(.-)"$')
					if key and value then
						if key == "model_provider" then
							provider_name = value
						elseif key == "model" then
							settings.model = value
						elseif key == "model_reasoning_effort" then
							settings.reasoning_effort = value
						elseif key == "preferred_auth_method" then
							settings.auth_method = map_codex_auth_method(value)
						elseif key == "base_url" and provider_name and current_provider == provider_name then
							settings.base_url = value
						elseif key == "wire_api" and provider_name and current_provider == provider_name then
							settings.wire_api = value
						end
					else
						local num_key, num_value = line_content:match("^([%w_]+)%s*=%s*(%d+)$")
						local bool_key, bool_value = line_content:match("^([%w_]+)%s*=%s*(true|false)$")
						if num_key == "submit_when_normal_retries" and num_value then
							settings.submit_when_normal_retries = tonumber(num_value)
						elseif bool_key == "disable_response_storage" and bool_value then
							settings.store = (bool_value ~= "true")
						end
					end
				end
			end
		end
	end

	if vim.fn.filereadable(auth_path) == 1 then
		local ok, auth = pcall(vim.json.decode, table.concat(vim.fn.readfile(auth_path), "\n"))
		if ok and type(auth) == "table" then
			settings.api_key = auth.OPENAI_API_KEY
		end
	end

	return settings
end

M.build_codex_http_url = function(base_url, wire_api)
	-- 规范化 base_url：优先使用传入值，默认 OpenAI 官方地址，并去掉末尾斜杠
	local codex_http_url = trim_slash(base_url or "https://api.openai.com")

	-- 如果已经是完整的 /responses 路径，直接返回，避免重复拼接
	if codex_http_url:match("/responses$") then
		return codex_http_url
	end

	-- 有些网关使用 /openai/responses（不带 /v1），OpenAI 官方使用 /v1/responses
	-- 当 wire_api 指定为 responses 且 base_url 以 /openai 结尾时，走网关兼容路径
	if wire_api == "responses" and codex_http_url:match("/openai$") then
		return codex_http_url .. "/responses"
	end

	-- 如果 base_url 已经包含 /v1，只需补上 /responses
	if codex_http_url:match("/v1$") then
		return codex_http_url .. "/responses"
	end

	-- 默认情况：补齐 /v1/responses
	return codex_http_url .. "/v1/responses"
end

local function extract_output_text_from_response(json)
	if type(json) ~= "table" or type(json.output) ~= "table" then
		return nil
	end

	for _, item in ipairs(json.output) do
		if item.type == "message" and type(item.content) == "table" then
			for _, block in ipairs(item.content) do
				if block.type == "output_text" and type(block.text) == "string" then
					return block.text
				end
			end
		end
	end
	return nil
end

local function parse_sse_response_text(body)
	local deltas = {}
	local completed_text

	for line in tostring(body):gmatch("[^\r\n]+") do
		local payload = line:match("^data:%s*(.+)$")
		if payload and payload ~= "" and payload ~= "[DONE]" then
			local ok, json = pcall(vim.json.decode, payload, { luanil = { object = true } })
			if ok and type(json) == "table" then
				if json.type == "response.output_text.delta" and type(json.delta) == "string" then
					table.insert(deltas, json.delta)
				elseif json.type == "response.completed" then
					completed_text = extract_output_text_from_response(json.response)
				end
			end
		end
	end

	if #deltas > 0 then
		return table.concat(deltas, "")
	end
	return completed_text
end

M.parse_codex_inline_response = function(data)
	if not data or data == "" then
		return { status = "error", output = "No output from the model" }
	end

	local body = type(data) == "table" and data.body or data
	if type(body) ~= "string" then
		body = tostring(body)
	end

	-- 兼容网关返回标准 JSON 的情况
	local ok, json = pcall(vim.json.decode, body, { luanil = { object = true } })
	if ok and type(json) == "table" then
		local text = extract_output_text_from_response(json)
		if text and text ~= "" then
			return { status = "success", output = text }
		end
	end

	-- 兼容网关返回 SSE 文本流（data: ...）的情况
	local sse_text = parse_sse_response_text(body)
	if sse_text and sse_text ~= "" then
		return { status = "success", output = sse_text }
	end

	return { status = "error", output = body }
end

M.sanitize_codex_response_parameters = function(params)
	if type(params) ~= "table" then
		return params
	end

	-- 兼容严格网关：移除常见但不被支持的参数
	params.top_p = nil
	params.temperature = nil
	params.top_logprobs = nil
	params.text = nil
	params.include = nil

	if type(params.reasoning) == "table" then
		params.reasoning.summary = nil
		if vim.tbl_isempty(params.reasoning) then
			params.reasoning = nil
		end
	end

	params.stream = true
	return params
end

local function detect_package_manager(cwd)
	if vim.fn.filereadable(cwd .. "/pnpm-lock.yaml") == 1 then
		return "pnpm"
	end
	if vim.fn.filereadable(cwd .. "/yarn.lock") == 1 then
		return "yarn"
	end
	return "npm"
end

M.codecompanion_select_npm_script = function(chat)
	local cwd = vim.fn.getcwd()
	local package_json = cwd .. "/package.json"
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

	local scripts = {}
	for name, command in pairs(json.scripts) do
		table.insert(scripts, {
			name = name,
			command = command,
			display = string.format("%-20s %s", name, command),
		})
	end

	table.sort(scripts, function(left, right)
		return left.name < right.name
	end)

	local displays = vim.tbl_map(function(script)
		return script.display
	end, scripts)

	require("fzf-lua").fzf_exec(displays, {
		prompt = "选择 npm script> ",
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local selected_display = selected[1]
				for _, script in ipairs(scripts) do
					if script.display == selected_display then
						local package_manager = detect_package_manager(cwd)
						local run_cmd = string.format("%s run %s", package_manager, script.name)
						local message = string.format(
							"请帮我执行这个命令: `%s` (script: %s, command: %s)",
							run_cmd,
							script.name,
							script.command
						)

						vim.schedule(function()
							local add_ok, err = pcall(function()
								chat:add_message({
									role = "user",
									content = message,
								}, { visible = true })
								if chat.submit then
									chat:submit()
								end
							end)
							if not add_ok then
								vim.notify("添加消息失败: " .. tostring(err), vim.log.levels.ERROR)
							end
						end)
						break
					end
				end
			end,
		},
	})
end

M.codecompanion_select_rules = function(chat)
	local ok_helpers, helpers = pcall(require, "codecompanion.interactions.chat.rules.helpers")
	local ok_rules, rules = pcall(require, "codecompanion.interactions.chat.rules")
	if not ok_helpers or not ok_rules then
		vim.notify("加载 CodeCompanion rules 模块失败", vim.log.levels.ERROR)
		return
	end

	local rule_items = helpers.list(chat)
	if not rule_items or vim.tbl_isempty(rule_items) then
		vim.notify("当前没有可用 rules", vim.log.levels.WARN)
		return
	end

	local displays = {}
	for index, item in ipairs(rule_items) do
		local display = string.format("%d. %s", index, item.name)
		if item.description and item.description ~= "" then
			display = string.format("%s — %s", display, item.description)
		end
		table.insert(displays, display)
	end

	require("fzf-lua").fzf_exec(displays, {
		prompt = "选择 rules> ",
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local selected_index = tonumber((selected[1] or ""):match("^%s*(%d+)%."))
				if not selected_index or not rule_items[selected_index] then
					vim.notify("无法解析选中的 rule", vim.log.levels.ERROR)
					return
				end

				local chosen_rule = rule_items[selected_index]
				vim.schedule(function()
					local ok, err = pcall(function()
						rules
							.new({
								name = chosen_rule.name,
								files = chosen_rule.files,
								opts = chosen_rule.opts,
								parser = chosen_rule.parser,
							})
							:make({ chat = chat, force = true })
					end)
					if not ok then
						vim.notify("加载 rule 失败: " .. tostring(err), vim.log.levels.ERROR)
					end
				end)
			end,
		},
	})
end

local function read_text_file(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	return table.concat(vim.fn.readfile(path), "\n")
end

M.codecompanion_skill_creator_doc = function()
	local content = read_text_file(vim.fn.expand("~/.config/agents/skills/skill-creator/SKILL.md"))
	if content then
		return content
	end
	return "Skill creator 文档未找到"
end

-- 加载指定技能目录下的 SKILL.md 文档内容
-- @param skill_name string|nil 技能名称，可为空
-- @return string 文档内容；若技能不存在则返回错误提示
M.codecompanion_load_skill_doc = function(skill_name)
	local skill = vim.trim(skill_name or "")
	-- 传入空名称时，直接返回未找到提示
	if skill == "" then
		return "Skill not found: "
	end

	-- 拼接技能文档路径：~/.config/agents/skills/<skill>/SKILL.md
	local skill_file = vim.fn.expand("~/.config/agents/skills/" .. skill .. "/SKILL.md")
	local content = read_text_file(skill_file)

	-- 文件不存在或读取失败时返回未找到提示
	if not content then
		return "Skill not found: " .. skill
	end

	-- 返回技能文档内容
	return content
end

return M
