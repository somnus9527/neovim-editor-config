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

M.load_global_conf = function ()
  local conf_path = M.path.join(M.path.conf_root(), const.conf_file_name)
  return ini_parser.load(conf_path)
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

M.get_codelldb_path = function()
  local conf = M.load_conf()
  -- 我没有linux, 所以不考虑linux的情况
  local extension_path = const.is_windows and conf.default.lldb_win_path or conf.default.lldb_mac_path
  local codelldb_path = extension_path .. 'adapter' .. const.path_separator .. 'codelldb'
  local liblldb_path = extension_path .. 'lldb' .. const.path_separator .. 'lib' .. const.path_separator .. 'liblldb'
  if const.is_windows then
    codelldb_path = extension_path .. 'adapter' .. const.path_separator .. 'codelldb.exe'
    liblldb_path = extension_path .. 'lldb' .. const.path_separator .. 'lib' .. const.path_separator .. 'liblldb.dll'
  else
    liblldb_path = liblldb_path .. '.dylib'
  end
  return {
    codelldb_path = codelldb_path,
    liblldb_path = liblldb_path,
  }
end

M.get_buf_filetype = function()
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_option(bufnr, 'filetype')
end

M.is_valid_filetype = function(filetype)
  for _, ft in ipairs(const.js_based_languages) do
    if filetype == ft then
      return true
    end
  end
  return false
end

M.is_git_project = function()
  local path = vim.loop.cwd() .. '/.git'
  local ok = vim.loop.fs_stat(path)
  if ok == nil then
    return false
  end
  return true
end

M.folder_is_contain_patterns = function()
  local current_dir = vim.fn.expand '%:p:h'
  local res = false
  for _, pattern in ipairs(const.workspace_auto_add_patterns) do
    local exist = vim.loop.fs_stat(current_dir .. const.path_separator .. pattern)
    if exist then
      res = true
    end
  end
  return res
end

-- Lua函数，将文件移动到回收站
M.trash_file = function(file_path)
  local cmd = vim.fn.system('trash ' .. vim.fn.fnameescape(file_path))
  if const.is_windows then
    -- 使用PowerShell命令移动文件到回收站
    cmd = string.format('powershell Remove-ItemSafely -Path "%s"', file_path)
  end
  -- 调用vim.fn.system()执行删除命令
  vim.fn.system(cmd)
end

-- 删除除当前文件之外的其它所有未修改的buffer
M.delete_other_unmodified_buffers = function()
  -- 获取当前 buffer 号码
  local current_bufnr = vim.api.nvim_get_current_buf()

  -- 获取所有 buffer 号码列表
  local bufnrs = vim.api.nvim_list_bufs()

  -- 遍历所有 buffer
  for _, bufnr in ipairs(bufnrs) do
    -- 如果不是当前 buffer，并且未修改，则关闭它
    if bufnr ~= current_bufnr and not vim.api.nvim_buf_get_option(bufnr, 'modified') then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end
end

return M
