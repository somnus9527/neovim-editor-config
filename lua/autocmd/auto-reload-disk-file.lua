-- 自动从磁盘同步文件
-- 如果在tmux中使用的neovim，需要手动在.tmux.conf文件中开启如下配置：
-- set -g focus-events on
-- 然后刷新tmux
-- tmux source-file ~/.tmux.conf
-- 没有就创建这个文件
-- touce ~/.tmux.conf
-- 该文件内容可参考README.md中的：.tmux.conf文件示例
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
  pattern = "*",
  command = "checktime",
})
