local M = {}
local is_windows = vim.loop.os_uname().version:match 'Windows'
local path_separator = is_windows and '\\' or '/'

M.path = {
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
    'Cargo.toml'
  }
end

M.is_web_project = function()
  -- 这里简单认为有package.json就是前端项目
  return M.root_has_file {
    'package.json'
  }
end

return M
