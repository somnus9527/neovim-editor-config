return {
  'jose-elias-alvarez/null-ls.nvim',
  dependencies = {
    'jose-elias-alvarez/typescript.nvim',
  },
  opts = function()
    local nls = require 'null-ls'
    return {
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
        -- 需要安装eslint_d
        nls.builtins.formatting.eslint_d,
        nls.builtins.diagnostics.eslint_d,
        require 'typescript.extensions.null-ls.code-actions',
        -- format json & markdown
        nls.builtins.formatting.deno_fmt.with {
          filetypes = { 'json', 'markdown' },
        },
        -- json diagnostics
        nls.builtins.diagnostics.jsonlint,
        -- markdown diagnostics
        -- nls.builtins.diagnostics.markdownlint,
        -- format yaml
        nls.builtins.formatting.yamlfix,
        -- yaml diagnostics
        nls.builtins.diagnostics.yamllint,
        -- c/c++ diagnostics
        nls.builtins.diagnostics.clang_check,
        -- c/c++ formatting
        nls.builtins.formatting.clang_format,
        -- cmake diagnostics
        nls.builtins.diagnostics.cmake_lint,
        -- cmake formatting
        nls.builtins.formatting.cmake_format,
      },
    }
  end,
}
