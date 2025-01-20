require "nvchad.options"

-- add yours here!

local o = vim.o
local opt = vim.opt
local g = vim.g

o.number = true
o.relativenumber = true
o.termguicolors = true
o.linespace = 0
o.cursorline = true
o.cmdheight = 2
o.swapfile = false
o.shadafile = "NONE"
o.backup = false
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.autoindent = true
o.smartindent = true
o.numberwidth = 4
-- 使用 Treesitter 的折叠表达式
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
-- 自动打开文件时不折叠
o.foldlevelstart = 99
o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"

opt.shortmess = opt.shortmess + "c"
-- 不使用系统粘贴板
opt.clipboard = ""

if g.neovide then
  g.neovide_input_ime = true
  g.neovide_input_macos_option_key_is_meta = "only_left"
  -- 字体
  o.guifont = "ComicShannsMono Nerd Font:h15"
  -- 对比度
  g.neovide_text_gamma = 0.0
  g.neovide_text_contrast = 0.5
  -- neovide 内边距
  g.neovide_padding_top = 0
  g.neovide_padding_bottom = 0
  g.neovide_padding_right = 0
  g.neovide_padding_left = 0
  -- 透明度
  local alpha = function()
    return string.format("%x", math.floor(255 * g.transparency or 0.8))
  end
  g.neovide_transparency = 0.0
  g.transparency = 0.95
  g.neovide_background_color = "#0f1117" .. alpha()
  -- title bar 颜色
  g.neovide_title_background_color =
    string.format("%x", vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name "Normal" }).bg)
  g.neovide_title_text_color = "pink"
  -- blurred
  -- g.neovide_window_blurred = true
  g.neovide_remember_window_size = true
end
