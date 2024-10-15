-- 使用 autocmd 来关闭 quickfix 窗口
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>:cclose<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "n", "q", "<CR>:cclose<CR>", { noremap = true, silent = true })
  end,
})
