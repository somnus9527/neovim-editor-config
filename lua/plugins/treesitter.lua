return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'windwp/nvim-ts-autotag',
  },
  config = function()
    require('nvim-treesitter.install').compilers = { 'clang' }
    local install = {
      'lua',
      'javascript',
      'css',
      'html',
      'jsdoc',
      'scss',
      'typescript',
      'vue',
      'xml',
      'yaml',
      'json',
      'jsonc',
      'markdown_inline',
    }
    require('nvim-treesitter.configs').setup {
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        -- filetypes = { 'html', 'xml' },
      },
      ensure_installed = install,
      highlight = {
        enable = true,
        -- disable = {
        --   "txt"
        -- }
        additional_vim_regex_highlighting = false,
        use_languagetree = false,
        disable = function(lang, buf)
          local max_filesize = 50 * 1024 -- 50 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          -- 取消所有非install对象里的语言的高亮
          for _, value in ipairs(install) do
            -- vim.print(lang)
            if value == lang then
              return false
            end
          end
          return true
        end,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = 'v',
          node_decremental = 'V',
        },
      },
    }
  end,
}
