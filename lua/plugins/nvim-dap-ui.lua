return {
  'rcarriga/nvim-dap-ui',
  lazy = true,
  module = true,
  opts = {},
  config = function(_, opts)
    local dap = require 'dap'
    local dap_ui = require 'dapui'
    local tools = require 'tools.tools'
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
        '<leader>du',
        function()
          dap_ui.toggle {}
        end,
        { desc = 'DapUI Toggle' },
      },
      {
        { 'n', 'v' },
        '<leader>de',
        function()
          dap_ui.eval()
        end,
        { desc = 'DapUI Eval' },
      },
    }
    tools.set_keymap(keymaps)
  end,
}
