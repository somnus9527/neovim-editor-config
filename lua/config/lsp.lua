-- 配置server
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" }
        }
      }
    }
  }
}

for server, config in pairs(servers) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- 配置server end
-- 配置diagnostic
local icons = require("tools.icons")
local diagnostic = {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●"
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
}
vim.diagnostic.config(diagnostic)
-- 配置diagnostic end
-- lsp相关快捷键配置
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local extend = function(opt)
      local re_opt = {}
      if opt then
        re_opt = vim.tbl_deep_extend('force', opts, opt)
      end
      return re_opt
    end

    local map = vim.keymap
    map.set('n', 'gd', vim.lsp.buf.definition, extend { desc = '跳转Definition' })
    map.set('n', 'gD', vim.lsp.buf.declaration, extend { desc = '跳转Declaration' })
    map.set('n', 'gr', vim.lsp.buf.references, extend { desc = '显示References' })
    map.set('n', 'gi', vim.lsp.buf.implementation, extend { desc = '显示Implementation' })
    map.set('n', '<leader>r', vim.lsp.buf.rename, extend { desc = '重命名' })
    -- map.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
    -- map.set('n', '<leader>f', lsp_formatting, { desc = 'Format' })
    map.set('n', 'K', vim.lsp.buf.hover, extend { desc = 'Hover展示代码说明' })
    map.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', extend { desc = '展示报错详情' })
  end,
})
-- lsp相关快捷键配置 end
