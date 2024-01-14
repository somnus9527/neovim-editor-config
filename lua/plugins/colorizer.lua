return {
  'NvChad/nvim-colorizer.lua',
  config = function ()
  	require 'colorizer'.setup {
      filetypes = {
        'css',
        'less',
        'scss',
        'sass',
        'javascript',
        'jsx',
        'typescript',
        'tsx',
        'vue'
      }
    }
  end
}
