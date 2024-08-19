local const = require "tools.const"

local M = {}

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
