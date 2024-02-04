return require('telescope').register_extension {
  -- setup = function(ext_config, config)
  --   -- access extension config and user config
  -- end,
  exports = {
    switch_indent = require('switch_indent'),
  },
}
