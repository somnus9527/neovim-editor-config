return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    local lsp = require 'lspconfig'
    local M = require 'configs.icons'
    -- 配置diagnostics

    for name, icon in pairs(M.diagnostics) do
      local name = 'DiagnosticSign' .. name
      vim.fn.sign_define(name, { texthl = name, text = icon, numhl = '' })
    end
    local config = {
      virtual_text = false, -- disable virtual text
      signs = {
        active = signs, -- show signs
      },
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

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'rounded',
    })

    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = 'rounded',
    })
    local lsp_formatting = function(bufnr)
      vim.lsp.buf.format {
        filter = function(client)
          -- 方法来自null-ls官网，限制lsp.format使用null-ls
          return client.name == 'null-ls'
        end,
        bufnr = bufnr,
      }
    end
    -- local util = lsp.util
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    lsp.lua_ls.setup {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
        },
      },
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
    -- 前置安装 npm install -g @vue/language-server
    local util = require 'lspconfig.util'
    local function get_typescript_server_path(root_dir)
      local global_ts = 'C:\\Users\\Administrator\\AppData\\Roaming\\npm\\node_modules\\typescript\\lib'
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
    -- 取消lsp的diagnostics，使用null-ls的服务
    vim.lsp.handlers['textDocument/publishDiagnostics'] = function() end

    -- 快捷键配置
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
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
        map.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, { desc = 'Code Action' })
        map.set('n', '<leader><space>', lsp_formatting, { desc = 'Format' })
        map.set('n', 'K', vim.lsp.buf.hover, extend { desc = 'Hover展示代码说明' })
        map.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', extend { desc = '展示报错详情' })
      end,
    })
  end,
}
