return {
  'nvim-treesitter/nvim-treesitter',
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
      'markdown_inline'
    }
    require('nvim-treesitter.configs').setup {
      ensure_installed = install,
      highlight = {
        enable = true,
        -- disable = {
        --   "txt"
        -- }
        disable = function(lang, buf)
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
        }
      }
    }
  end,
}
