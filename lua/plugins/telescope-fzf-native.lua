return {
  'nvim-telescope/telescope-fzf-native.nvim',
  lazy = true,
  module = true,
  build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
}
