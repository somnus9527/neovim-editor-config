return {
  'jose-elias-alvarez/null-ls.nvim',
  dependencies = {
    'jose-elias-alvarez/typescript.nvim',
  },
  opts = function()
    local nls = require 'null-ls'
    local diagnostics_fmt = '"[#{c}] #{m} (#{s})"'
    local tools = require 'tools.tools'
    local const = require 'tools.const'
    return {
      diagnostics_format = diagnostics_fmt,
      update_in_insert = false,
      root_dir = require('null-ls.utils').root_pattern(
        'package.json',
        'vue.config.js',
        '.null-ls-root',
        '.neoconf.json',
        'Makefile',
        '.git'
      ),
      sources = {
        -- 需要安装stylua
        nls.builtins.formatting.stylua,
        -- 需要安装luacheck
        -- TODO: luacheck 设置参数之后vim倒是不报错了，但是整个校验全失效了。。。服了
        -- nls.builtins.diagnostics.luacheck,
        -- nls.builtins.diagnostics.luacheck.with({
        --   extra_args = { '--globals', 'vim' }
        -- }),
        -- 需要安装eslint_d
        nls.builtins.formatting.eslint_d.with {
          diagnostics_format = diagnostics_fmt,
          condition = function()
            return tools.is_eslint_project()
          end,
        },
        nls.builtins.diagnostics.eslint_d.with {
          diagnostics_format = diagnostics_fmt,
          condition = function()
            return tools.is_eslint_project()
          end,
        },
        require 'typescript.extensions.null-ls.code-actions',
        -- deno_lint 不生效？？？？ 什么鬼
        -- 不是不生效是需要配deno.json，暂且这么搞，难道不配置我还不能报错了？？？
        -- lsp那边增加判断，如果前端项目，既没有eslint配置也没有prettier配置(那么这个项目还做JB?)，那么使用lsp的tsserver作为diagnostics服务
        -- nls.builtins.diagnostics.deno_lint.with {
        --   -- diagnostics_format = diagnostics_fmt,
        --   filetypes = { 'json', 'jsonc', 'markdown' },
        --   -- condition = function()
        --   --   return not utils.is_eslint_project()
        --   -- end,
        --   -- extra_args = { '-c', vim.fn.expand '~\\AppData\\Local\\nvim\\deno.json' },
        -- },
        -- xo 代替 deno_lint
        -- xo的规则一坨屎，取消
        -- nls.builtins.diagnostics.xo.with({
        --   diagnostics_format = diagnostics_fmt,
        --   condition = function(utils)
        --     return not cond_eslint(utils)
        --   end
        -- }),
        nls.builtins.formatting.prettierd.with {
          condition = function()
            return tools.is_prettier_project() and not tools.is_eslint_project()
          end,
        },
        nls.builtins.formatting.deno_fmt.with {
          filetypes = { 'json', 'jsonc', 'markdown' },
          -- condition = function()
          --   return not utils.is_eslint_project() and not utils.is_prettier_project()
          -- end,
          extra_args = { '-c', vim.fn.expand(const.conf_path .. const.path_separator .. 'deno.json' )},
        },
        -- format json & markdown
        -- nls.builtins.formatting.deno_fmt.with {
        --   filetypes = { 'json', 'jsonc', 'markdown' },
        -- },
        -- format json
        -- nls.builtins.formatting.json_tool,
        -- format markdown
        -- nls.builtins.formatting.markdownlint,
        -- json diagnostics
        nls.builtins.diagnostics.jsonlint.with {
          diagnostics_format = diagnostics_fmt,
        },
        -- markdown diagnostics
        nls.builtins.diagnostics.markdownlint,
        -- format yaml
        nls.builtins.formatting.yamlfix,
        -- yaml diagnostics
        nls.builtins.diagnostics.yamllint.with {
          diagnostics_format = diagnostics_fmt,
          extra_args = { '-c', vim.fn.expand(const.conf_path .. const.path_separator .. '.yamllint.yaml')},
        },
        -- c/c++ diagnostics
        nls.builtins.diagnostics.clang_check.with {
          diagnostics_format = diagnostics_fmt,
          extra_args = { '-X', 'cxx' }
        },
        -- c/c++ formatting
        nls.builtins.formatting.clang_format,
        -- cmake diagnostics
        nls.builtins.diagnostics.cmake_lint.with {
          diagnostics_format = diagnostics_fmt,
        },
        -- cmake formatting
        nls.builtins.formatting.cmake_format,
        -- rust formatting
        nls.builtins.formatting.rustfmt,
        -- toml formatting
        nls.builtins.formatting.taplo,
      },
    }
  end,
}
