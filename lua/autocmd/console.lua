-- 为 JavaScript、TypeScript 和相关文件添加自动插入日志的能力
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  callback = function()
    -- 检查 Tree-sitter 是否已正确加载
    if not pcall(require, "nvim-treesitter") then
      return
    end
    local ts_utils = require "nvim-treesitter.ts_utils" -- 修正为 ts_utils

    -- 定义全局函数 insert_console_log_with_scope
    _G.insert_console_log_with_scope = function()
      local variable = vim.fn.expand "<cword>"
      local file_path = vim.fn.expand "%:p"
      local relative_path = vim.fn.fnamemodify(file_path, ":~:.")
      local icon = "🚀"
      local tag = "[Somnus9527 Log]"

      -- 获取当前的 Tree-sitter 节点
      local node = ts_utils.get_node_at_cursor()
      if not node then
        return
      end

      -- 优化作用域路径解析
      local function get_scope_path(node)
        local path = {}
        while node do
          local node_type = node:type()
          -- 检查是否是函数、方法或类等节点
          if node_type == "call_expression" then
            local function_node = node:child(0)
            if function_node and function_node:type() == "identifier" then
              local func_name = ts_utils.get_node_text(function_node)[1]
              table.insert(path, 1, func_name)
            end
          else
            local name_node = node:field("name")[1] or node:field("id")[1] -- 尝试多种字段名称
            if name_node then
              local name_text = ts_utils.get_node_text(name_node)[1]
              if name_text then
                table.insert(path, 1, name_text) -- 插入路径从最里层到最外层
              end
            end
          end
          node = node:parent()
        end
        return table.concat(path, ".")
      end
      local scope_path = get_scope_path(node)
      if scope_path == "" then
        scope_path = "Global"
      end

      -- 生成 console.log 语句
      local log_statement = string.format(
        "console.log('%s %s: path = %s, scope = %s, %s = ', %s);",
        icon,
        tag,
        relative_path,
        scope_path,
        variable,
        variable
      )

      -- 插入 log 语句
      vim.api.nvim_put({ log_statement }, "l", true, true)
    end

    -- 绑定快捷键，仅在首次加载时
    if not vim.g.console_log_keymap_set then
      vim.api.nvim_set_keymap(
        "n",
        "<leader>cc",
        ":lua insert_console_log_with_scope()<CR>",
        { noremap = true, silent = true }
      )
      vim.g.console_log_keymap_set = true
    end
  end,
})
