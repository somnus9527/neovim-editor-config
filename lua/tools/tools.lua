local M = {}

-- 获取当前cwd的项目类型
function M.detect_project_type()
  local markers = {
    { name = "angular.json",   type = "angular" },
    { name = "vue.config.js",  type = "vue" },
    { name = "vite.config.js", type = "vue" },
    { name = "package.json",   type = "web" },
    -- { name = "Cargo.toml",     type = "rust" },
    -- { name = "pyproject.toml", type = "python" },
    -- { name = "pubspec.yaml",   type = "flutter" },
  }
  local cwd = vim.fn.getcwd()
  for _, marker in ipairs(markers) do
    if vim.fn.filereadable(cwd .. "/" .. marker.name) == 1 or vim.fn.isdirectory(cwd .. "/" .. marker.name) == 1 then
      return marker.type
    end
  end
  return "default"
end

return M
