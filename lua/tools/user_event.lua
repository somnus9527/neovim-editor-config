local M = {}

-- 内部事件数据缓存（用于 User 事件）
local _event_data = {}

--- 监听 User 事件
---@param event string 事件名
---@param callback fun(data: table|nil)
function M.on_user(event, callback)
  vim.api.nvim_create_autocmd("User", {
    pattern = event,
    callback = function()
      local data = _event_data[event]
      callback(data or {}) -- 传空表以防止 callback 内部报错
    end,
  })
end

--- 触发 User 事件并传递数据
---@param event string
---@param data table|nil
function M.emit_user(event, data)
  _event_data[event] = data or {}
  vim.api.nvim_exec_autocmds("User", { pattern = event })
end

--- 监听通过 `vim.api.nvim_command("doautocmd User X")` 触发的事件
---@param event string
---@param callback fun()
function M.on_cmd(event, callback)
  vim.api.nvim_create_autocmd("User", {
    pattern = event,
    callback = callback,
  })
end

--- 直接执行 vim 命令字符串
---@param cmd string
function M.emit_cmd(cmd)
  vim.api.nvim_command(cmd)
end

return M