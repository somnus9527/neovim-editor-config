local is_ok, fzf = pcall(require, 'fzf-lua')

if not is_ok then
  return
end

local tools = require 'tools.tools'
local config_opts = tools.load_conf()
local items = config_opts.default.indent == 2 and { '4', '2' } or { '2', '4' }

_G.SwitchIndent = function()
  fzf.fzf_exec(items, {
    prompt = 'SwitchIndent> ',
    actions = {
      ['default'] = function(selected)
        local val = selected[1]
        vim.cmd('set tabstop=' .. val .. ' shiftwidth=' .. val .. ' softtabstop=' .. val)
        local c_config_opts = tools.load_global_conf()
        c_config_opts.default.indent = val
        tools.save_conf(c_config_opts)
      end,
    },
  })
end

local keymaps = {
  { 'n', '<leader><TAB>', '<CMD>lua SwitchIndent()<CR>', { desc = '切换Tab Indent' } },
}

tools.set_keymap(keymaps)
