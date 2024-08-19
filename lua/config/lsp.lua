local icons_ok, icons = pcall(require, 'config.icons')
if not icons_ok then
  return
end

local mason_ok, mason = pcall(require, 'mason')
if not mason_ok then
  return
end

local mason_opt = {
  ui = {
    icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
    }
  }
}
mason.setup(mason_opt)

local mason_lsp_ok, mason_lsp = pcall(require, 'mason-lspconfig')
if not mason_lsp_ok then
  return
end

local mason_lsp_opt = {
  ensure_installed = {
    "lua_ls"
  }
}
mason_lsp.setup(mason_lsp_opt)

local navbuddy_ok, navbuddy = pcall(require, 'nvim-navbuddy')
if not navbuddy_ok then
  return
end

local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_ok then
  return
end

-- 配置diagnostics图标
for name, icon in pairs(icons.diagnostics) do
  local diagnostic_name = 'DiagnosticSign' .. name
  vim.fn.sign_define(diagnostic_name, { texthl = diagnostic_name, text = icon, numhl = '' })
end
-- diagnostics配置
local config = {
  virtual_text = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}
vim.diagnostic.config(config)
-- 配置hover样式
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})
-- 配置signatureHelp样式
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})

local on_attach = function (client, buffer)
  navbuddy.attach(client, buffer)
end

-- 开始服务配置
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  -- 主要处理undefinded global vim 报错, 方案来自https://github.com/neovim/neovim/discussions/24119
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
              -- Depending on the usage, you might want to add additional paths here.
              -- E.g.: For using `vim.*` functions, add vim.env.VIMRUNTIME/lua.
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            },
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          },
        },
      })
    end
    return true
  end,
});


-- 其余lspserver相关配置
-- 快捷键配置
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
    map.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
    -- map.set('n', '<leader>f', lsp_formatting, { desc = 'Format' })
    map.set('n', 'K', vim.lsp.buf.hover, extend { desc = 'Hover展示代码说明' })
    map.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', extend { desc = '展示报错详情' })
  end,
})
