-- 一些副作用操作
-- 自动创建 undo 目录
local undodir = vim.opt.undodir:get()[1]
-- print(vim.inspect(vim.opt.undodir:get()))
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
