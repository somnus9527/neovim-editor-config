local M = {}

-- 默认快捷键配置参数
M.default_keymap_opt = {
  silent = true,
  noremap = true,
}

-- 项目类型分类
M.project_markers = {
  { name = "angular.json",   type = "angular" },
  { name = "vue.config.js",  type = "vue" },
  { name = "vite.config.js", type = "vue" },
  { name = "package.json",   type = "web" },
  -- { name = "Cargo.toml",     type = "rust" },
  -- { name = "pyproject.toml", type = "python" },
  -- { name = "pubspec.yaml",   type = "flutter" },
}

-- 是否windows环境
M.is_windows = vim.loop.os_uname().version:match 'Windows'

-- path分隔符
M.path_separator = M.is_windows and '\\' or '/'

-- 配置路径
M.conf_path = M.is_windows and '~\\AppData\\Local\\nvim' or '~/.config/nvim'

return M