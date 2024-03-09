local is_path_ok, Path = pcall(require, 'plenary.path')
if not is_path_ok then
  vim.notify 'Plenary Path Util Got Error!'
  return
end

local M = {}
M.colon_replacer = '++'
M.path_replacer = '__'

M.dir_to_workspace_filename = function(dir)
  local filename = dir:gsub(':', M.colon_replacer)
  filename = filename:gsub(Path.path.sep, M.path_replacer)
  return filename
end

M.workspace_filename_to_dir = function(filename)
  local dir = filename:gsub(M.colon_replacer, ':')
  dir = dir:gsub(M.path_replacer, Path.path.sep)
  return dir
end

return M
