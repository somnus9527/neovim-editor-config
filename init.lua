-- 配置leader
vim.g.nofsync = true
vim.g.mapleader = ","

require("lazy_bootstrap")
require("configs.normal")
require("keymaps.keymaps")
