local M = {}
M.js_based_languages = {
  'typescript',
  'javascript',
  'typescriptreact',
  'javascriptreact',
  'vue',
}
M.is_windows = vim.loop.os_uname().version:match 'Windows'
M.path_separator = M.is_windows and '\\' or '/'
M.default_keymap_opt = {
  silent = true,
  noremap = true,
}
M.conf_path = M.is_windows and '~\\AppData\\Local\\nvim' or '~/.config/nvim'
M.eslint_project_definition = {
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
  -- 有的场景会出现eslint配置在package.json中，但是加上package.json之后对于没有配置eslint规则的项目就无法使用别的服务了，所以注释掉
  -- 'package.json',
}
M.typescript_project_definition = {
  'tsconfig.json',
}
M.lua_project_definition = {
  '.stylua.toml',
  'lazy-lock.json',
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
M.rust_project_definition = {
  'Cargo.toml',
  'rustfmt.toml',
}
M.web_project_definition = {
  'package.json',
}
M.tailwind_definition = {
  'tailwind.config.js',
  'tailwind.config.cjs',
  'tailwind.config.mjs',
  'tailwind.config.ts',
}
M.conf_file_name = 'conf.ini'
M.local_conf_file_name = 'local_conf.ini'
M.session_base_path = vim.fn.stdpath 'data' .. '/sessions'
M.workspace_base_path = vim.fn.stdpath 'data' .. '/workspaces'
M.workspace_auto_add_patterns = {
  '.git',
  '.svn',
  'package.json',
  'Cargo.toml',
  'CMakeLists.txt',
  '.vs',
}

return M
