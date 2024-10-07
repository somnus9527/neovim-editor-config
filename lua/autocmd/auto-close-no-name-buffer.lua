vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre' }, {
  pattern = "*",
  callback = function()
    -- 获取所有列出的 buffer 信息
    local buffers = vim.fn.getbufinfo { buflisted = 1 }

    -- 当有多个 buffer 时才进行清理
    if #buffers > 1 then
      for _, buf in ipairs(buffers) do
        -- 检查 buffer 是否无名并且内容为空
        if buf.name == "" and buf.linecount == 1 and vim.fn.getbufline(buf.bufnr, 1)[1] == "" then
          -- 删除该无名 buffer
          vim.cmd("silent! bdelete " .. buf.bufnr)
        end
      end
    end
  end,
})
