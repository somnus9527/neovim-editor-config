local M = {}

-- 默认快捷键配置参数
M.default_keymap_opt = {
  silent = true,
  noremap = true,
}

-- 项目类型分类
M.project_markers = {
  angular = {
    "angular.json",
  },
  vue = {
    "vue.config.js",
    "vite.config.js",
    "vite.config.ts",
  },
  web = {
    "package.json",
  },
  -- rust = { "Cargo.toml" },
  -- python = { "pyproject.toml" },
  -- flutter = { "pubspec.yaml" },
}

-- 是否windows环境
M.is_windows = vim.loop.os_uname().version:match 'Windows'

-- path分隔符
M.path_separator = M.is_windows and '\\' or '/'

-- 配置路径
M.conf_path = M.is_windows and '~\\AppData\\Local\\nvim' or '~/.config/nvim'

return M
