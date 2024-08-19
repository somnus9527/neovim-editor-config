local const = require "tools.const"

local M = {}

M.path = {
  path_separator = const.path_separator,
  conf_root = function()
    return vim.fn.expand(const.conf_path)
  end,
  root = function()
    return vim.loop.cwd()
  end,
  exists = function(filename)
    local stat = vim.loop.fs_stat(filename)
    return stat ~= nil
  end,
  join = function(...)
    return table
      .concat(vim.tbl_flatten { ... }, const.path_separator)
      :gsub(const.path_separator .. '+', const.path_separator)
  end,
}

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

M.is_git_project = function()
  -- local path = vim.loop.cwd() .. '/.git'
  -- local ok = vim.loop.fs_stat(path)
  -- if ok == nil then
  --   return false
  -- end
  -- return true
  local handle = io.popen 'git rev-parse --is-inside-work-tree 2>/dev/null'
  local result = handle:read '*a'
  handle:close()
  return result:match '^true'
end

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
  return M.root_has_file(const.eslint_project_definition)
end

M.is_prettier_project = function()
  return M.root_has_file(const.prettier_project_definition)
end

M.show_todo = function()
  local fzf = require('fzf-lua')

  -- 使用 ripgrep 搜索 TODO 项
  local command = "rg --files-with-matches --ignore-case --no-heading --color never 'TODO'"

  -- 执行命令并获取结果
  local results = vim.fn.systemlist(command)

  -- 使用 fzf-lua 显示结果
  fzf.fzf(results, {
    prompt = 'TODO > ',
    previewer = 'bat', -- 可选：使用 bat 作为预览工具
    preview = {
      default = 'bat',
      bat_opts = '--color=always',
    },
  })
end

return M
