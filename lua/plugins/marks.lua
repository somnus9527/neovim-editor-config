return {
  'chentoast/marks.nvim',
  config = function()
    local opt = {
      default_mappings = false,
    }
    require('marks').setup { opt }
  end,
}
