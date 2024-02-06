return {
  'mxsdev/nvim-dap-vscode-js',
  module = true,
  enabled = false,
  dependencies = {
    'microsoft/vscode-js-debug',
  },
  config = function()
    local dap_vscode = require 'dap-vscode-js'
    local opts = {
      -- 这一行必须设置
      debugger_path = vim.fn.resolve(vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug'),
      adapters = {
        'chrome',
        'pwa-node',
        'pwa-chrome',
        'pwa-msedge',
        'pwa-extensionHost',
        'node-terminal',
      },
    }
    dap_vscode.setup(opts)
  end,
}
