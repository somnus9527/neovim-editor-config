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
    -- capabilities.textDocument.completion.completionItem.snippetSupport = true
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
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
    require('lspconfig').cssls.setup {
      capabilities = capabilities,
    }
    -- 前置安装 npm install -g cssmodules-language-server
    require('lspconfig').cssmodules_ls.setup {
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
    require('lspconfig').html.setup {
      capabilities = capabilities,
    }
    -- 前置安装 npm i -g vscode-langservers-extracted
    require('lspconfig').jsonls.setup {
      capabilities = capabilities,
    }
    -- 前置安装 npm install -g @vue/language-server
    require('lspconfig').volar.setup {
      filetypes = { 'vue' },
      capabilities = capabilities,
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
        map.set('n', 'gD', vim.lsp.buf.declaration, extend {desc = '跳转Declaration'})
        map.set('n', 'gr', vim.lsp.buf.references, extend {desc = '显示References'})
        map.set('n', 'gi', vim.lsp.buf.implementation, extend {desc = '显示Implementation'})
        map.set('n', '<leader>r', vim.lsp.buf.rename, extend {desc = '重命名'})
        map.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, {desc = 'Code Action'})
        map.set('n', '<leader><space>', lsp_formatting, {desc = 'Format'})
        map.set('n', 'K', vim.lsp.buf.hover, extend {desc = 'Hover展示代码说明'})
        map.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', extend {desc = '展示报错详情'})
      end,
    })
  end,
}
