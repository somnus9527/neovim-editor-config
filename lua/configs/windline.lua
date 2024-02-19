local windline = require 'windline'
local helper = require 'windline.helpers'
local icons = require 'configs.icons'
local sep = helper.separators
local vim_components = require 'windline.components.vim'

local b_components = require 'windline.components.basic'
local state = _G.WindLine.state

local lsp_comps = require 'windline.components.lsp'
local git_comps = require 'windline.components.git'

local hl_list = {
  Black = { 'white', 'black' },
  White = { 'black', 'white' },
  Inactive = { 'InactiveFg', 'InactiveBg' },
  Active = { 'ActiveFg', 'ActiveBg' },
}
local spaces = function()
  return 'Spaces: ' .. vim.api.nvim_buf_get_option(0, 'shiftwidth') .. ' '
end
local line_format = function()
  local format_icons = {
    unix = 'LF(UNIX) ',
    dos = 'CRLF(DOS) ',
    mac = 'LF(MAC) ',
  }
  return function()
    return format_icons[vim.bo.fileformat] or vim.bo.fileformat
  end
end
local basic = {}

basic.divider = { b_components.divider, '' }
basic.file_name_inactive = { b_components.file_name('default', 'short'), hl_list.Inactive }
basic.line_col_inactive = { b_components.line_col, hl_list.Inactive }
basic.progress_inactive = { b_components.progress, hl_list.Inactive }

basic.vi_mode = {
  name = 'vi_mode',
  hl_colors = {
    Normal = { 'black', 'red', 'bold' },
    Insert = { 'black', 'green', 'bold' },
    Visual = { 'black', 'yellow', 'bold' },
    Replace = { 'black', 'blue_light', 'bold' },
    Command = { 'black', 'magenta', 'bold' },
    NormalBefore = { 'red', 'black' },
    InsertBefore = { 'green', 'black' },
    VisualBefore = { 'yellow', 'black' },
    ReplaceBefore = { 'blue_light', 'black' },
    CommandBefore = { 'magenta', 'black' },
    NormalAfter = { 'white', 'red' },
    InsertAfter = { 'white', 'green' },
    VisualAfter = { 'white', 'yellow' },
    ReplaceAfter = { 'white', 'blue_light' },
    CommandAfter = { 'white', 'magenta' },
  },
  text = function()
    return {
      { sep.left_rounded, state.mode[2] .. 'Before' },
      { state.mode[1] .. ' ', state.mode[2] },
      { sep.left_rounded, state.mode[2] .. 'After' },
    }
  end,
}

basic.lsp_diagnos = {
  name = 'diagnostic',
  hl_colors = {
    red = { 'red', 'black' },
    yellow = { 'yellow', 'black' },
    blue = { 'blue', 'black' },
  },
  width = 90,
  text = function(bufnr)
    if lsp_comps.check_lsp(bufnr) then
      return {
        { lsp_comps.lsp_error { format = ' ' .. icons.diagnostics.Error .. ' %s' }, 'red' },
        { lsp_comps.lsp_warning { format = ' ' .. icons.diagnostics.Warn .. ' %s' }, 'yellow' },
        { lsp_comps.lsp_hint { format = ' ' .. icons.diagnostics.Hint .. ' %s' }, 'blue' },
      }
    end
    return ''
  end,
}

basic.file = {
  name = 'file',
  hl_colors = {
    default = hl_list.White,
  },
  text = function()
    return {
      { b_components.cache_file_icon { default = icons.kinds.File }, 'default' },
      { ' ', 'default' },
      { b_components.cache_file_name('[No Name]', 'shorten') },
      { b_components.file_modified(' ' .. icons.git.modified) },
      { b_components.cache_file_size() },
    }
  end,
}

basic.mid = {
  hl_colors = {
    sep_before = { 'black_light', 'black' },
    sep_after = { 'black_light', 'black' },
    text = { 'orange', 'black_light' },
  },
  text = function(buf)
    if lsp_comps.check_lsp(buf) then
      return {
        { sep.left_rounded, 'sep_before' },
        { lsp_comps.lsp_name(), 'text' },
        { sep.right_rounded, 'sep_after' },
      }
    end
    return {
      { b_components.cache_file_type { icon = true, default = '' } },
    }
  end,
}

basic.right = {
  hl_colors = {
    branch_name_before = { 'deepgreen', 'black' },
    branch_name_after = { 'deeppurple', 'deepgreen' },
    sep_before = { 'deeppurple', 'midgray' },
    sep_after = { 'deeppurple', 'black' },
    text = { 'white', 'deeppurple' },
    branch_name = { 'orange', 'deepgreen' },
    line_format_before_black = { 'lightgray', 'black' },
    line_format_before = { 'lightgray', 'deepgreen' },
    line_format_after = { 'deeppurple', 'lightgray' },
    line_format = { 'black_light', 'lightgray' },
    encode_before = { 'midgray', 'lightgray' },
    encode_after = { 'midgray', 'midgray' },
    encode = { 'black_light', 'midgray' },
  },
  text = function(buf)
    -- local branch =
    -- { git_comps.git_branch { icon = icons.git.branch .. ' ' }, 'branch_name', 130 }
    local option = {
      -- { sep.left_rounded, 'branch_name_before' },
      -- {' ', 'branch_name'},
      -- {' ', 'branch_name'},
      -- { sep.left_rounded, 'branch_name_after' },
      -- { sep.left_rounded, 'sep_before' },
      -- { sep.left_rounded, 'line_format_before' },
      { line_format(), 'line_format' },
      -- { sep.left_rounded, 'line_format_after' },
      { sep.left_rounded, 'encode_before' },
      { b_components.file_encoding(), 'encode' },
      { sep.left_rounded, 'encode_after' },
      { sep.left_rounded, 'sep_before' },
      { ' Row:Col', 'text' },
      { b_components.line_col_lua },
      { '' .. icons.Other.Progress },
      { b_components.progress_lua },
      { sep.right_rounded, 'sep_after' },
    }
    if git_comps.is_git(buf) then
      table.insert(option, 1, { sep.left_rounded, 'branch_name_before' })
      table.insert(option, 2, { ' ', 'branch_name' })
      table.insert(option, 3, { git_comps.git_branch { icon = icons.git.branch .. ' ' }, 'branch_name', 130 })
      table.insert(option, 4, { ' ', 'branch_name' })
      table.insert(option, 5, { sep.left_rounded, 'line_format_before' })
    else
      table.insert(option, 1, { sep.left_rounded, 'line_format_before_black' })
    end
    return option
  end,
}
basic.git = {
  name = 'git',
  width = 90,
  hl_colors = {
    green = { 'green', 'black' },
    red = { 'red', 'black' },
    blue = { 'blue', 'black' },
  },
  text = function(bufnr)
    if git_comps.is_git(bufnr) then
      return {
        { ' ' },
        { git_comps.diff_added { format = icons.git.added .. '%s' }, 'green' },
        { git_comps.diff_removed { format = ' ' .. icons.git.removed .. '%s' }, 'red' },
        { git_comps.diff_changed { format = ' ' .. icons.git.modified .. '%s' }, 'blue' },
      }
    end
    return ''
  end,
}

local default = {
  filetypes = { 'default' },
  active = {
    { ' ', hl_list.Black },
    basic.vi_mode,
    basic.file,
    { vim_components.search_count(), { 'red', 'white' } },
    { sep.right_rounded, hl_list.Black },
    basic.lsp_diagnos,
    basic.git,
    basic.divider,
    basic.mid,
    basic.divider,
    { ' ', hl_list.Black },
    basic.right,
    { ' ', hl_list.Black },
  },
  inactive = {
    basic.file_name_inactive,
    basic.divider,
    basic.divider,
    basic.line_col_inactive,
    { '', hl_list.Inactive },
    basic.progress_inactive,
  },
}

local quickfix = {
  filetypes = { 'qf', 'Trouble' },
  active = {
    { '🚦 Quickfix ', { 'white', 'black' } },
    { helper.separators.slant_right, { 'black', 'black_light' } },
    {
      function()
        return vim.fn.getqflist({ title = 0 }).title
      end,
      { 'cyan', 'black_light' },
    },
    { ' Total : %L ', { 'cyan', 'black_light' } },
    { helper.separators.slant_right, { 'black_light', 'InactiveBg' } },
    { ' ', { 'InactiveFg', 'InactiveBg' } },
    basic.divider,
    { helper.separators.slant_right, { 'InactiveBg', 'black' } },
    { icons.Other.Quickfixlogo .. ' ', { 'white', 'black' } },
  },
  always_active = true,
  show_last_status = true,
}

local explorer = {
  filetypes = { 'neo-tree' },
  active = {
    { ' ' .. icons.Other.Module .. ' ', { 'white', 'black_light' } },
    { helper.separators.slant_right, { 'black_light', 'NormalBg' } },
    { b_components.divider, '' },
    { b_components.file_name(icons.kinds.File), { 'NormalFg', 'NormalBg' } },
  },
  always_active = true,
  show_last_status = true,
}

windline.setup {
  colors_name = function(colors)
    -- lsp背景色
    colors.lspbg = '#fe8019'
    colors.deepgreen = '#006869'
    colors.deeppurple = '#75729b'
    colors.purple = '#a29ed9'
    colors.orange = '#fc8615'
    colors.deeporange = '#87511c'
    colors.lightgray = '#a4accd'
    colors.midgray = '#bdc1cf'
  end,
  statuslines = {
    default,
    explorer,
    quickfix,
  },
  git = 'branch',
}
