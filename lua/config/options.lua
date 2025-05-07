-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local o = vim.o
local opt = vim.opt
local g = vim.g

if not vim.g.vscode then
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

  g.autoformat = false
  g.root_spec = { "lsp", "cwd", { ".git", "lua" } }

  opt.wrap = true
  o.linebreak = true
  o.breakindent = true
  o.showbreak = '↪'

  if g.neovide then
    -- 处理mac alt按键失效的问题
    if not vim.loop.os_uname().version:match('Windows') then
      g.neovide_input_macos_option_key_is_meta = 'only_left'
    end
  end

  vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = {
      severity = vim.diagnostic.severity.ERROR,
    },
    severity_sort = true,
  });
else
  -- 不使用系统粘贴板
  opt.clipboard = ""
  -- 配置连词符
  opt.iskeyword:append({ "_", "-" })
end
