local function custom_esc_behavior()
  -- 检查是否存在搜索高亮
  if vim.v.hlsearch == 1 then
    -- 存在搜索高亮时，取消高亮
    vim.cmd 'nohlsearch'
  else
    -- 不存在搜索高亮时，发送 <Esc> 实现默认行为
    -- 注意：使用 vim.api.nvim_feedkeys 时需要将键按字符串转义
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  end
end

-- 将该函数注册为全局可访问，以便在键映射中使用
_G.custom_esc_behavior = custom_esc_behavior
