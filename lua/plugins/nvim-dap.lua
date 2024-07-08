return {
  'mfussenegger/nvim-dap',
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'mxsdev/nvim-dap-vscode-js',
    'microsoft/vscode-js-debug',
    'Joakker/lua-json5',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    local dap = require 'dap'
    local dap_utils = require 'dap.utils'
    local widgets = require 'dap.ui.widgets'
    local icons = require 'tools.icons'
    local tools = require 'tools.tools'
    local const = require 'tools.const'
    require 'configs.dap-cpp'
    -- 设置断点行展示Visual样式
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })
    -- 设置debug时各种状态的icon
    for name, sign in pairs(icons.dap) do
      sign = type(sign) == 'table' and sign or { sign }
      vim.fn.sign_define(
        'Dap' .. name,
        { text = sign[1], texthl = sign[2] or 'DiagnosticInfo', linehl = sign[3], numhl = sign[3] }
      )
    end
    for _, language in ipairs(const.js_based_languages) do
      dap.configurations[language] = {
        -- Debug single nodejs files
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug current file',
          cwd = vim.fn.getcwd(),
          args = { '${file}' },
          sourceMaps = true,
          protocol = 'inspector',
        },
        -- Debug nodejs processes (make sure to add --inspect when you run the process)
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Debug NodeJS Progress (need --inspect)',
          processId = dap_utils.pick_process,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
        },
        -- Debug web applications (client side)
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Debug SPA with Chrome',
          -- url = 'http://localhost:5173',
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = 'Enter PWA URL: ',
                default = 'http://localhost:3000',
              }, function(url)
                if url == nil or url == '' then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          webRoot = '${workspaceFolder}',
          userDataDir = '${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir',
        },
        -- Divider for the launch.json derived configs
        {
          name = '----- ↓ launch.json configs ↓ ----- Do Nothing -----',
          type = '',
          request = 'launch',
        },
      }
    end
    local run_with_args = function()
      if vim.fn.filereadable '.vscode/launch.json' then
        require('dap.ext.vscode').json_decode = require('json5').parse
        local dap_vscode = require 'dap.ext.vscode'
        dap_vscode.load_launchjs(nil, {
          ['pwa-node'] = const.js_based_languages,
          ['chrome'] = const.js_based_languages,
          ['pwa-chrome'] = const.js_based_languages,
        })
      end
      dap.continue()
    end
    local keymaps = {
      {
        'n',
        '<leader>ds',
        run_with_args,
        { desc = 'Run With Args | <F1> Start|Continue' },
      },
      {
        'n',
        '<leader>db',
        function()
          dap.toggle_breakpoint()
        end,
        { desc = 'Toggle Breakpoint | <F2> Step Over' },
      },
      {
        'n',
        '<leader>dB',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        { desc = 'Set Breakpoint Condition | <F3> Step Into' },
      },
      {
        'n',
        '<F1>',
        function()
          dap.continue()
        end,
        { desc = 'Continue | <F4> Step Out' },
      },
      {
        'n',
        '<leader>dd',
        function()
          dap.run_to_cursor()
        end,
        { desc = 'Run to Cursor' },
      },
      {
        'n',
        '<leader>dg',
        function()
          dap.goto_()
        end,
        { desc = 'Go to line(No Execute)' },
      },
      {
        'n',
        '<F3>',
        function()
          dap.step_into()
        end,
        { desc = 'Step Into' },
      },
      {
        'n',
        '<leader>dj',
        function()
          dap.down()
        end,
        { desc = 'Down' },
      },
      {
        'n',
        '<leader>dk',
        function()
          dap.up()
        end,
        { desc = 'Up' },
      },
      {
        'n',
        '<leader>dl',
        function()
          dap.run_last()
        end,
        { desc = 'Run Last' },
      },
      {
        'n',
        '<F4>',
        function()
          dap.step_out()
        end,
        { desc = 'Step Out' },
      },
      {
        'n',
        '<F2>',
        function()
          dap.step_over()
        end,
        { desc = 'Step Over' },
      },
      {
        'n',
        '<leader>dp',
        function()
          dap.pause()
        end,
        { desc = 'Pause' },
      },
      {
        'n',
        '<leader>dr',
        function()
          dap.repl.toggle()
        end,
        { desc = 'REPL Toggle' },
      },
      {
        'n',
        '<leader>dS',
        function()
          dap.session()
        end,
        { desc = 'Session' },
      },
      {
        'n',
        '<leader>dq',
        function()
          dap.terminate()
        end,
        { desc = 'Terminate' },
      },
      {
        'n',
        '<leader>dh',
        function()
          widgets.hover()
        end,
        { desc = 'Hover' },
      },
    }
    tools.set_keymap(keymaps)
  end,
}
