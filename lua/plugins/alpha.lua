return {
  'goolord/alpha-nvim',
  dependencies = {
    'natecraddock/workspaces.nvim',
    'natecraddock/sessions.nvim',
  },
  config = function()
    require 'configs.alpha'
  end,
}
