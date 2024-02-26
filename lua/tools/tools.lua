local ini_parser = require 'tools.ini_parser'
local const = require 'tools.const'

local M = {}

M.path = {
  path_separator = const.path_separator,
  conf_root = function()
    return vim.fn.expand(const.conf_path)
  end,
  root = function()
    return vim.loop.cwd()
  end,
  exists = function(filename)
    local stat = vim.loop.fs_stat(filename)
    return stat ~= nil
  end,
  join = function(...)
    return table
      .concat(vim.tbl_flatten { ... }, const.path_separator)
      :gsub(const.path_separator .. '+', const.path_separator)
  end,
}

M.merge_table = function(opt1, opt2)
  local re_opt = {}
  if opt1 and opt2 then
    re_opt = vim.tbl_deep_extend('force', opt1, opt2)
  end
  return re_opt
end

M.extend_opt = function(opts)
  local re_opt = {}
  if opts then
    re_opt = vim.tbl_deep_extend('force', const.default_keymap_opt, opts)
  end
  return re_opt
end

M.set_keymap = function(keymaps)
  local keymap = vim.keymap

  for _, value in pairs(keymaps) do
    keymap.set(value[1], value[2], value[3], M.extend_opt(value[4] or {}))
  end
end

M.set_buf_keymap = function(keymaps)
  local api = vim.api

  for _, value in pairs(keymaps) do
    api.nvim_buf_set_keymap(0, value[1], value[2], value[3], M.extend_opt(value[4] or {}))
  end
end

M.root_has_file = function(...)
  local patterns = vim.tbl_flatten { ... }
  local root = M.path.root()
  for _, name in ipairs(patterns) do
    if M.path.exists(M.path.join(root, name)) then
      return true
    end
  end
  return false
end

M.is_eslint_project = function()
  return M.root_has_file(const.eslint_project_definition)
end

M.is_lua_conf_project = function()
  return M.root_has_file(const.lua_project_definition)
end

M.is_prettier_project = function()
  return M.root_has_file(const.prettier_project_definition)
end

M.is_rust_project = function()
  return M.root_has_file(const.rust_project_definition)
end

M.is_web_project = function()
  -- 这里简单认为有package.json就是前端项目
  return M.root_has_file(const.web_project_definition)
end

M.read_file = function(file_path)
  local fd = io.open(file_path, 'r')
  if not fd then
    error(('Could not open file %s for reading'):format(file_path))
  end
  local data = fd:read '*a'
  fd:close()
  return data
end

M.write_file = function(file_path, data)
  local fd = io.open(file_path, 'w+')
  if not fd then
    error(('Could not open file %s for writing'):format(file_path))
  end
  fd:write(data)
  fd:close()
end

M.exist_file = function(path)
  local fd = io.open(path, 'r')
  if fd ~= nil then
    io.close(fd)
    return true
  else
    return false
  end
end

M.load_conf = function()
  local conf_path = M.path.join(M.path.conf_root(), const.conf_file_name)
  local local_conf_path = M.path.join(M.path.conf_root(), const.local_conf_file_name)
  local opts = ini_parser.load(conf_path)
  if M.exist_file(local_conf_path) then
    local local_opts = ini_parser.load(local_conf_path)
    for k, v in pairs(local_opts) do
      for sk, sv in pairs(v) do
        opts[k][sk] = sv
      end
    end
  end
  return opts
end

M.save_conf = function(data)
  local conf_path = M.path.join(M.path.conf_root(), const.conf_file_name)
  ini_parser.save(conf_path, data)
end

M.make_timestamp = function(str)
  local inYear, inMonth, inDay, inHour, inMinute, inSecond, inZone =
    string.match(str, '^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)$')

  local zHours, zMinutes = string.match(inZone, '^(.-):(%d%d)$')

  local returnTime = os.time {
    year = inYear,
    month = inMonth,
    day = inDay,
    hour = inHour,
    min = inMinute,
    sec = inSecond,
    isdst = false,
  }
  if zHours then
    returnTime = returnTime - ((tonumber(zHours) * 3600) + (tonumber(zMinutes) * 60))
  end

  return returnTime
end

M.get_session_path = function(workspace_name)
  local file_name = '.session'
  if workspace_name then
    file_name = '.' .. workspace_name .. '_session'
  end
  return const.session_base_path .. file_name
end

return M
