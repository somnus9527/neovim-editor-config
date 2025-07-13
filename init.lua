local project_type = require('tools.tools').detect_project_type()

local entry_map = {
  angular = "entry.angular",
  vue2 = "entry.vue2",
  vue3 = "entry.vue3",
  web = "entry.web",
  default = "entry.default",
}

local entry_path = entry_map[project_type];

-- 引入entry
if entry_path then
  require(entry_path)
end

-- 加载Lazy插件管理
require('entry.lazy')