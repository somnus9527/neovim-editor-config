local project_type = require('tools.tools').detect_project_type()
local config_map = {
  angular = "config.angular.index",
  vue = "config.vue.index",
  web = "config.web.index",
  default = "config.default.index",
}

local config_path = config_map[project_type];
if config_path then
  require(config_path)
end