local pickers = require 'telescope.pickers'
local actions = require 'telescope.actions'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local action_state = require 'telescope.actions.state'
local utils = require 'utils'
local create_finder = function(t)
  local config_opts = utils.load_conf()
  local indent_config = config_opts.default.indent == 2 and { '4', '2' } or { '2', '4' }
  return finders.new_table {
    results = indent_config,
  }
end
local switch_indent = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Switch Indention',
      finder = create_finder(),
      previewer = nil,
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local value = selection[1]
          -- TODO: 配置options
          vim.cmd('set tabstop=' .. value .. ' shiftwidth=' .. value .. ' softtabstop=' .. value)
          local config_opts = utils.load_conf()
          config_opts.default.indent = value
          utils.save_conf(config_opts)
        end)
        return true
      end,
    })
    :find()
end

return switch_indent
