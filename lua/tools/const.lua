local M = {}

M.is_windows = vim.loop.os_uname().version:match 'Windows'
M.path_separator = M.is_windows and '\\' or '/'
M.conf_path = M.is_windows and '~\\AppData\\Local\\nvim' or '~/.config/nvim'

M.default_keymap_opt = {
  silent = true,
  noremap = true,
}

M.eslint_project_definition = {
  -- '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
  -- 有的场景会出现eslint配置在package.json中，但是加上package.json之后对于没有配置eslint规则的项目就无法使用别的服务了，所以注释掉
  -- 'package.json',
}

M.prettier_project_definition = {
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

return M
