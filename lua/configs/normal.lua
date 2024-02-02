local utils = require 'utils'
local o = vim.o
local g = vim.g
local opt = vim.opt

-- 判断是否在neovide中
if g.neovide then
  -- 是neovide环境，将外边界置0
  g.neovide_padding_top = 0
  g.neovide_padding_left = 0
  g.neovide_padding_right = 0
  g.neovide_padding_bottom = 0
  -- 设置背景透明度 start
  local alpha = function()
    return string.format('%x', math.floor((255 * vim.g.transparency) or 0.8))
  end
  g.neovide_transparency = 0.95
  g.transparency = 0.95
  g.neovide_background_color = '#0f1012' .. alpha()
  -- 设置背景透明度 end
  -- 浮动窗口设置 start 除了第一个开启/关闭控制，其余都是设置阴影效果的，官方解释看不懂
  g.neovide_floating_shadow = true
  -- 设置浮框距背景的虚拟高度
  g.neovide_floating_z_height = 10
  -- 设置投射光与屏幕法线的角度 。。。
  g.neovide_light_angle_degrees = 45
  -- 设置投射光半径
  g.neovide_light_radius = 5
  -- 浮动窗口设置 end
  -- 设置滚动动画时常
  g.neovide_scroll_animation_length = 0
  -- 设置一次滚动超过一屏，最后多少行开始执行滚动动画
  g.neovide_scroll_animation_far_lines = 30
  -- 设置输入时隐藏光标
  g.neovide_hide_mouse_when_typing = true
  -- 兼容性不好的功能关了
  g.neovide_unlink_border_highlights = false
  -- 设置启动全屏
  -- g.neovide_fullscreen = true
  -- 记住上一次窗口的size
  g.neovide_remember_window_size = true
  -- 打开profiler=true
  g.neovide_profiler = false
  -- 设置光标动画
  g.neovide_cursor_animation_length = 0.03
  -- 设置光标动画尾巴长度
  g.neovide_cursor_trail_size = 0.8
  -- 设置光标粒子效果
  g.neovide_cursor_vfx_mode = 'ripple'
  -- 设置刷新率
  g.neovide_refresh_rate = 60
  g.neovide_refresh_rate_idle = 20
  -- 设置neovide缩放
  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  local keymaps = {
    {
      'n',
      '<C-=>',
      function()
        change_scale_factor(1.25)
      end,
      { desc = '放大窗口' },
    },
    {
      'n',
      '<C-->',
      function()
        change_scale_factor(1 / 1.25)
      end,
      { desc = '缩小窗口' },
    },
  }
  utils.set_keymap(keymaps)
end

-- 显示相对行号
o.relativenumber = true
-- 开启终端使用GUI颜色
o.termguicolors = true
-- gui 模式下使用的字体
o.guifont = 'JetBrainsMono Nerd Font Mono:h12'
-- 设置行间距
o.linespace = 0
-- 高亮当前列
-- o.cursorcolumn = true
-- 高亮当前行
o.cursorline = true
-- 命令行使用的行数
o.cmdheight = 2
-- 行号使用的列数
o.numberwidth = 4
-- 缓冲区不使用交换文件
o.swapfile = false
-- tab转空格配置 start
-- 设置文件里Tab代表的空格数
o.tabstop = 2
-- (自动) 缩进每一步使用的空白数目
o.shiftwidth = 2
-- 编辑时tab代表的空格数
o.softtabstop = 2
-- 插入模式里: 插入 <Tab> 时使用合适数量的空格
o.expandtab = 2
-- 自动缩进
o.autoindent = true
o.smartindent = true
-- tab转空格配置 end
-- opt.lazyredraw = true
g.rust_recommended_style = 0
-- 不可见字符设置为可见
-- o.list = true
-- o.listchars = { tab = '>>', trail = '-', nbsp = '+' }
g.git_messenger_no_default_mappings = true
