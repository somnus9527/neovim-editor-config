local dap_ok, dap = pcall(require, 'dap')

if not dap_ok then
  return
end

local tools = require 'tools.tools'
local adapters = tools.get_codelldb_path()

dap.adapters = {
  codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = adapters.codelldb_path,
      args = { '--port', '${port}' }
    }
  }
}

dap.configurations.cpp = {
  {
    name = 'Debug Cpp',
    type = 'codelldb',
    request = 'launch',
    program = function ()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd(), 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  }
}
