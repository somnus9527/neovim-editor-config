-- 为前端相关语言优化keyword配置
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css", "vue", "json" },
  callback = function()
    vim.opt_local.iskeyword:append("-")
    vim.opt_local.iskeyword:append("_")
  end,
})
