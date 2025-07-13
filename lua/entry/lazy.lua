-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)

local project_type = require('tools.tools').detect_project_type()
local plugins_map = {
  angular = "plugins.angular",
  vue = "plugins.vue",
  web = "plugins.web",
}
local spec = {
  { import = "plugins.common" },
}
local spec_plugins = plugins_map[project_type]
if spec_plugins then
  table.insert(spec, { import = spec_plugins })
end
-- Setup lazy.nvim
require("lazy").setup({
  colorscheme = "catppuccin",
  spec = spec,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
