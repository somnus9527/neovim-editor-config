local ok, lsp = pcall(require, 'lspconfig')
if not ok then
  return
end
local icons = require 'tools.icons'
local tools = require 'tools.tools'
local const = require 'tools.const'
-- 配置diagnostics图标
for name, icon in pairs(icons.diagnostics) do
  local name = 'DiagnosticSign' .. name
  vim.fn.sign_define(name, { texthl = name, text = icon, numhl = '' })
end
-- diagnostics配置
local config = {
  virtual_text = true, -- disable virtual text
  update_in_insert = true,
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
-- 使用null-ls格式化
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format {
    filter = function(client)
      if tools.is_web_project() and not tools.is_eslint_project() and not tools.is_prettier_project() then
        local filetype = tools.get_buf_filetype()
        local is_valid = tools.is_valid_filetype(filetype)
        if is_valid then
          return client.name == 'tsserver'
        else
          return client.name == 'null-ls'
        end
      end
      -- 方法来自null-ls官网，限制lsp.format使用null-ls
      return client.name == 'null-ls'
    end,
    bufnr = bufnr,
  }
end
-- 获取优化版lsp-cmp capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lsp.lua_ls.setup {
  capabilities = capabilities,
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
}
-- 前置安装 npm install -g typescript typescript-language-server
lsp.tsserver.setup {
  capabilities = capabilities,
}
-- 前置安装 npm i -g vscode-langservers-extracted
lsp.cssls.setup {
  capabilities = capabilities,
}
-- 前置安装 npm install -g cssmodules-language-server
lsp.cssmodules_ls.setup {
  capabilities = capabilities,
}
-- 前置安装 npm i -g vscode-langservers-extracted
-- require'lspconfig'.eslint.setup{
--   -- capabilities = capabilities,
--   root_dir = util.root_pattern(".git", "package.json", "jsconfig", "tsconfig"),
--   settings = {
--       nodePath = "C:/Users/Administrator/AppData/Roaming/npm/"
--   }
-- }
-- 前置安装 npm i -g vscode-langservers-extracted
lsp.html.setup {
  capabilities = capabilities,
}
-- 前置安装 npm i -g vscode-langservers-extracted
lsp.jsonls.setup {
  capabilities = capabilities,
}
local util = require 'lspconfig.util'
local global_opts = tools.load_conf()
local function get_typescript_server_path(root_dir)
  local global_ts = tools.is_windows and global_opts.default.typescript_win_path
    or global_opts.default.typescript_mac_path
  -- 需要自己配置本地global的typescript地址
  local found_ts = ''
  local function check_dir(path)
    found_ts = util.path.join(path, 'node_modules', 'typescript', 'lib')
    if util.path.exists(found_ts) then
      return path
    end
  end
  if util.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    return global_ts
  end
end
lsp.volar.setup {
  filetypes = { 'vue' },
  capabilities = capabilities,
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
}
-- 前置安装 npm install yaml-language-server -g
lsp.yamlls.setup {
  capabilities = capabilities,
}
-- 前置安装下载地址：https://github.com/artempyanykh/marksman/releases；并添加到全局path
lsp.marksman.setup {
  capabilities = capabilities,
}
-- 前置安装 npm install emmet-ls -g
lsp.emmet_ls.setup {
  capabilities = capabilities,
  filetypes = {
    'css',
    'html',
    'javascript',
    'javascriptreact',
    'less',
    'sass',
    'scss',
    'svelte',
    'pub',
    'typescriptreact',
    'vue',
  },
  init_options = {
    html = {
      options = {
        ['bem.enabled'] = true,
      },
    },
  },
}
-- toml
lsp.taplo.setup {
  capabilities = capabilities,
}
-- cmake
lsp.cmake.setup {
  capabilities = capabilities,
  filetypes = {
    'cmake',
    'CMakeLists.txt',
  },
}

-- angular
local opts = tools.load_conf()
if opts.default.pnpm_win_path then
  local project_library_path = const.is_windows and opts.default.pnpm_win_path or opts.default.pnpm_mac_path
  local tssdk_path = get_typescript_server_path(vim.loop.cwd())
  local cmd =
    { 'ngserver', '--stdio', '--tsProbeLocations', tssdk_path, '--ngProbeLocations', project_library_path }
  local file = io.open(vim.fn.getcwd() .. '/node_modules/@angular/core/package.json', 'r')
  if file then
    local file_contents = file:read '*all'
    if tonumber(file_contents.match(file_contents, [["version": "(%d+).%d+.%d+"]])) < 9 then
      table.insert(cmd, '--viewEngine')
    end
  end
  lsp.angularls.setup {
    capabilities = capabilities,
    cmd = cmd,
    on_new_config = function(new_config)
      new_config.cmd = cmd
    end,
    root_dir = util.root_pattern('angular.json', 'project.json'),
  }
end

-- cpp
local clangd_capabilities = require('cmp_nvim_lsp').default_capabilities()
clangd_capabilities.textDocument.completion.completionItem.snippetSupport = true
clangd_capabilities.offsetEncoding = { 'utf-16' }
lsp.clangd.setup {
  capabilities = clangd_capabilities,
}
-- 取消lsp的diagnostics，使用null-ls的服务
-- 2024-02-13 不再全局取消,而是分情况而定,目前场景如下:
-- 1. lua项目还是使用lua_ls服务的diagnostics,主要null-ls的luacheck有问题,所以luacheck不需要再安装,null-ls那边的luacheck配置也需要取消
-- 2. rust项目没有比rust-analyzer更好的diagnostics选择
-- 3. web项目一般不会没有eslint,但是也有例外,对于例外,tsserver的报错
local publish_diagnostics = vim.lsp.handlers['textDocument/publishDiagnostics']
vim.lsp.handlers['textDocument/publishDiagnostics'] = function(...)
  local err, method, params, client_id = ...
  local do_publish = function()
    publish_diagnostics(err, method, params, client_id)
  end
  if tools.is_lua_conf_project() then
    do_publish()
  elseif tools.is_rust_project() then
    do_publish()
  elseif tools.is_web_project() then
    if not tools.is_eslint_project() and not tools.is_prettier_project() then
      do_publish()
    end
  end
end
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
    map.set('n', '<leader>f', lsp_formatting, { desc = 'Format' })
    map.set('n', 'K', vim.lsp.buf.hover, extend { desc = 'Hover展示代码说明' })
    map.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', extend { desc = '展示报错详情' })
  end,
})

-- 加载rustaceanvim配置
require 'configs.rustaceanvim'
