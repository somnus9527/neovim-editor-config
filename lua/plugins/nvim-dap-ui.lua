return {
  'rcarriga/nvim-dap-ui',
  module = true,
  opts = {},
  config = function(_, opts)
    local dap = require 'dap'
    local dap_ui = require 'dapui'
    local utils = require 'utils'
    dap_ui.setup { opts }
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dap_ui.open {}
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dap_ui.close {}
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dap_ui.close {}
    end
    local keymaps = {
      {
        'n',
        '<leader>cu',
        function()
          dap_ui.toggle {}
        end,
        { desc = 'DapUI Toggle' },
      },
      {
        { 'n', 'v' },
        '<leader>ce',
        function()
          dap_ui.eval()
        end,
        { desc = 'DapUI Eval' },
      },
    }
    utils.set_keymap(keymaps)
  end,
}
