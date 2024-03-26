-- 取消js文件备注中的缩进
function _G.javascript_indent()
  local line = vim.fn.getline(vim.v.lnum)
  local prev_line = vim.fn.getline(vim.v.lnum - 1)
  if line:match '^%s*[%*/]%s*' then
    if prev_line:match '^%s*%*%s*' then
      return vim.fn.indent(vim.v.lnum - 1)
    end
    if prev_line:match '^%s*/%*%*%s*$' then
      return vim.fn.indent(vim.v.lnum - 1) + 1
    end
  end

  return vim.fn['GetJavascriptIndent']()
end

-- 在ts和tsx中执行这段代码会造成缩进神奇的失效...
-- vim.cmd [[autocmd FileType javascript,javascriptreact,typescript,typescriptreact,vue setlocal indentexpr=v:lua.javascript_indent()]]
vim.cmd [[autocmd FileType javascript setlocal indentexpr=v:lua.javascript_indent()]]
