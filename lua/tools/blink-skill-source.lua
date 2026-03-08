local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
local uv = vim.uv or vim.loop

---@class BlinkSkillSourceOpts
---@field skill_roots string[]
---@field allowed_filetypes string[]
---@field include_system_skills boolean
---@field cache_ttl_ms integer
---@field max_scan_depth integer
---@field max_items integer

---@class BlinkSkillEntry
---@field name string
---@field path string
---@field description string
---@field is_system boolean

---@class BlinkSkillSourceCache
---@field timestamp integer
---@field skills BlinkSkillEntry[]

local source = {}

local function normalize_dir(path)
	local expanded = vim.fn.expand(path)
	return (expanded:gsub("/+$", ""))
end

local function is_dir(path)
	return vim.fn.isdirectory(path) == 1
end

local function table_contains(tbl, value)
	return type(tbl) == "table" and vim.tbl_contains(tbl, value)
end

local function list_skill_files(root, max_depth, include_system_skills)
	local files = {}

	local function walk(dir, depth)
		if depth > max_depth then
			return
		end

		local handle = uv.fs_scandir(dir)
		if not handle then
			return
		end

		while true do
			local name, entry_type = uv.fs_scandir_next(handle)
			if not name then
				break
			end

			local full_path = dir .. "/" .. name
			if entry_type == "directory" then
				if include_system_skills or name:sub(1, 1) ~= "." then
					walk(full_path, depth + 1)
				end
			elseif entry_type == "file" and name == "SKILL.md" then
				table.insert(files, full_path)
			end
		end
	end

	walk(root, 0)
	return files
end

local function read_skill_description(skill_file)
	local ok, lines = pcall(vim.fn.readfile, skill_file, "", 40)
	if not ok or type(lines) ~= "table" then
		return ""
	end

	local title = ""
	local description = ""
	for _, line in ipairs(lines) do
		local trimmed = vim.trim(line)
		if trimmed ~= "" then
			if title == "" and trimmed:match("^#%s+") then
				title = trimmed:gsub("^#%s+", "")
			elseif description == "" and not trimmed:match("^#") then
				description = trimmed
				break
			end
		end
	end

	if description ~= "" then
		return description
	end
	return title
end

local function collect_skills(opts)
	local by_name = {}

	for _, skill_root in ipairs(opts.skill_roots) do
		local root = normalize_dir(skill_root)
		if is_dir(root) then
			local skill_files = list_skill_files(root, opts.max_scan_depth, opts.include_system_skills)
			for _, skill_file in ipairs(skill_files) do
				local parent_dir = vim.fs.dirname(skill_file)
				local skill_name = vim.fs.basename(parent_dir)
				if skill_name and skill_name ~= "" then
					local is_system = skill_file:find("/.system/", 1, true) ~= nil
					local current = by_name[skill_name]
					if not current or (current.is_system and not is_system) then
						by_name[skill_name] = {
							name = skill_name,
							path = skill_file,
							description = read_skill_description(skill_file),
							is_system = is_system,
						}
					end
				end
			end
		end
	end

	local skills = vim.tbl_values(by_name)
	table.sort(skills, function(a, b)
		return a.name < b.name
	end)

	if #skills > opts.max_items then
		skills = vim.list_slice(skills, 1, opts.max_items)
	end

	return skills
end

function source.new(opts)
	local default_opts = {
		skill_roots = { "~/.codex/skills", "~/.config/agents/skills" },
		allowed_filetypes = { "codecompanion" },
		include_system_skills = true,
		cache_ttl_ms = 30000,
		max_scan_depth = 3,
		max_items = 80,
	}

	opts = vim.tbl_deep_extend("keep", opts or {}, default_opts)

	vim.validate({
		skill_roots = { opts.skill_roots, "table" },
		allowed_filetypes = { opts.allowed_filetypes, "table" },
		include_system_skills = { opts.include_system_skills, "boolean" },
		cache_ttl_ms = { opts.cache_ttl_ms, "number" },
		max_scan_depth = { opts.max_scan_depth, "number" },
		max_items = { opts.max_items, "number" },
	})

	local self = setmetatable({}, { __index = source })
	self.opts = opts
	self.cache = {
		timestamp = 0,
		skills = {},
	}

	return self
end

function source:enabled()
	if not self.opts.allowed_filetypes or vim.tbl_isempty(self.opts.allowed_filetypes) then
		return true
	end
	return table_contains(self.opts.allowed_filetypes, vim.bo.filetype)
end

function source:get_trigger_characters()
	return { "$" }
end

function source:get_skills()
	local now = uv.now()
	local cache_valid = (now - self.cache.timestamp) <= self.opts.cache_ttl_ms
	if cache_valid and self.cache.skills then
		return self.cache.skills
	end

	local ok, skills = pcall(collect_skills, self.opts)
	if ok and type(skills) == "table" then
		self.cache.timestamp = now
		self.cache.skills = skills
		return skills
	end

	return self.cache.skills or {}
end

local function get_skill_query(ctx)
	local cursor_col = ctx.cursor[2]
	local line_before_cursor = ctx.line:sub(1, cursor_col)
	local start_col = line_before_cursor:find("%$[%w_%-]*$")
	if not start_col then
		return nil
	end

	local query = line_before_cursor:sub(start_col + 1)
	return {
		query = query,
		start_col = start_col,
	}
end

function source:get_completions(ctx, callback)
	local query = get_skill_query(ctx)
	if not query then
		callback({
			context = ctx,
			is_incomplete_forward = false,
			is_incomplete_backward = false,
			items = {},
		})
		return
	end

	local edit_range = {
		start = {
			line = ctx.cursor[1] - 1,
			character = query.start_col - 1,
		},
		["end"] = {
			line = ctx.cursor[1] - 1,
			character = ctx.cursor[2],
		},
	}

	local items = {}
	for index, skill in ipairs(self:get_skills()) do
		items[index] = {
			kind = CompletionItemKind.Module,
			label = skill.name,
			filterText = "$" .. skill.name,
			sortText = string.format("%04d_%s", index, skill.name),
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
			textEdit = {
				newText = "$" .. skill.name,
				range = edit_range,
			},
			documentation = {
				kind = "markdown",
				value = string.format("`$%s`\n\n%s\n\n`%s`", skill.name, skill.description ~= "" and skill.description or "Skill", skill.path),
			},
			data = {
				type = "skill",
				path = skill.path,
				is_system = skill.is_system,
			},
		}
	end

	callback({
		context = ctx,
		is_incomplete_forward = false,
		is_incomplete_backward = false,
		items = items,
	})
end

return source
