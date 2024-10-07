local M = {}

M.default_keymap_opt = {
  silent = true,
  noremap = true,
}

--- 扩展设置keymap的opts
---@param opts 
---@return 
M.extend_opt = function(opts)
  local re_opt = {}
  if opts then
    re_opt = vim.tbl_deep_extend('force', M.default_keymap_opt, opts)
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

return M
