local const = require('tools.const')

local M = {}

--- 是否存在 marker（支持字符串或 Lua 模式）
local function marker_exists(marker)
  local cwd = vim.fn.getcwd()
  local path = cwd .. "/" .. marker

  -- 先直接判断文件或目录是否存在
  if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
    return true
  end

  -- 支持模式匹配（pattern）
  local files = vim.fn.readdir(cwd)
  for _, file in ipairs(files) do
    if file:match(marker) then
      return true
    end
  end

  return false
end

-- 获取当前cwd的项目类型
function M.detect_project_type()
  for project_type, markers in pairs(const.project_markers) do
    for _, marker in ipairs(markers) do
      if marker_exists(marker) then
        return project_type
      end
    end
  end
  return "default"
end

--- 扩展设置keymap的opts
---@param opts
---@return
M.extend_opt = function(opts)
  local re_opt = {}
  if opts then
    re_opt = vim.tbl_deep_extend('force', const.default_keymap_opt, opts)
  end
  return re_opt
end

--- 设置快捷键
---@param keymaps
M.set_keymap = function(keymaps)
  local keymap = vim.keymap

  for _, value in pairs(keymaps) do
    keymap.set(value[1], value[2], value[3], M.extend_opt(value[4] or {}))
  end
end

--- 设置当前buffer的快捷键
---@param keymaps
M.set_buf_keymap = function(keymaps)
  local api = vim.api

  for _, value in pairs(keymaps) do
    api.nvim_buf_set_keymap(0, value[1], value[2], value[3], M.extend_opt(value[4] or {}))
  end
end

-- 监听lazyvim提供的VeryLazy事件，执行回调
M.on_very_lazy = function(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = fn,
  })
end

return M
