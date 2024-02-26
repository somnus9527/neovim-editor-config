local filetypes = {
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
return {
  'NvChad/nvim-colorizer.lua',
  ft = filetypes,
  config = function ()
  	require 'colorizer'.setup {
      filetypes = filetypes,
    }
  end
}
