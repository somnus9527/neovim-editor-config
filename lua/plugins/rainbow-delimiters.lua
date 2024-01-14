return {
  'HiPhish/rainbow-delimiters.nvim',
  config = function()
    local rainbow_delimiters = require 'rainbow-delimiters'
    local rainbow_delimiters_setup = require 'rainbow-delimiters.setup'
    rainbow_delimiters_setup.setup {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
      },
      priority = {
        [''] = 110,
        lua = 210,
      },
      highlight = {
        'rainbowdelimiterred',
        'rainbowdelimiteryellow',
        'rainbowdelimiterblue',
        'rainbowdelimiterorange',
        'rainbowdelimitergreen',
        'rainbowdelimiterviolet',
        'rainbowdelimitercyan',
      },
    }
  end,
}
