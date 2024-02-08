local M = {}
local path_separator = M.is_windows and '\\' or '/'
M.is_windows = vim.loop.os_uname().version:match 'Windows'
M.path = {
  conf_root = function()
    return M.is_windows and vim.fn.expand '~\\AppData\\Local\\nvim' or vim.fn.expand '~/.config/nvim'
  end,
  root = function()
    return vim.loop.cwd()
  end,
  exists = function(filename)
    local stat = vim.loop.fs_stat(filename)
    return stat ~= nil
  end,
  join = function(...)
    return table.concat(vim.tbl_flatten { ... }, path_separator):gsub(path_separator .. '+', path_separator)
  end,
}

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
  return M.root_has_file {
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    '.eslintrc.json',
    -- 有的场景会出现eslint配置在package.json中，但是加上package.json之后对于没有配置eslint规则的项目就无法使用别的服务了，所以注释掉
    --         -- 'package.json',
  }
end

M.is_prettier_project = function()
  return M.root_has_file {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.yaml',
    '.prettierrc.yml',
    '.prettierrc.json5',
    '.prettierrc.js',
    'prettier.config.js',
    '.prettierrc.mjs',
    'prettier.config.mjs',
    '.prettierrc.cjs',
    'prettier.config.cjs',
    '.prettierrc.toml',
  }
end

M.is_rust_project = function()
  return M.root_has_file {
    'Cargo.toml',
  }
end

M.is_web_project = function()
  -- 这里简单认为有package.json就是前端项目
  return M.root_has_file {
    'package.json',
  }
end

M.default_keymap_opt = {
  silent = true,
  noremap = true,
}

M.extend_opt = function(opts)
  local re_opt = {}
  if opts then
    re_opt = vim.tbl_deep_extend('force', M.default_keymap_opt, opts)
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
  local ini = require 'ini'
  local conf_path = M.path.join(M.path.conf_root(), 'conf.ini')
  local opts = ini.load(conf_path)
  -- print(opts.default.indent)
  return opts
end

M.save_conf = function(data)
  local ini = require 'ini'
  local conf_path = M.path.join(M.path.conf_root(), 'conf.ini')
  ini.save(conf_path, data)
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

M.session_base_path = vim.fn.stdpath 'data' .. '/sessions/'

M.get_session_path = function(workspace_name)
  local file_name = '.session'
  if workspace_name then
    file_name = '.' .. workspace_name .. '_session'
  end
  return M.session_base_path .. file_name
end

return M
