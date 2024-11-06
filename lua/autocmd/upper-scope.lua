-- 快速跳转到上层作用域
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "css",
    "vue",
    "json",
    "less",
    "scss",
  },
  callback = function()
    _G.GoToParentScope = function()
      local ts_utils = require "nvim-treesitter.ts_utils"
      local node = ts_utils.get_node_at_cursor()
      if node then
        local parent = node:parent()
        if parent then
          ts_utils.goto_node(parent)
        end
      end
    end
    vim.api.nvim_set_keymap("n", "<leader>u", ":lua GoToParentScope()<CR>", { noremap = true, silent = true })
  end,
})
