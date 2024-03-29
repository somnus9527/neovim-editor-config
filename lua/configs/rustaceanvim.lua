local tools = require 'tools.tools'
local const = require 'tools.const'
vim.g.rustaceanvim = function()
  local adapters = tools.get_codelldb_path()
  return {
    -- 插件配置
    tools = {
      hover_actions = {
        auto_focus = true,
      }
    },
    server = {
      on_attach = function(client, bufnr)
        local opt = {
          silent = true,
          buffer = bufnr,
        }
        local merge_opt = function(desc)
          return tools.merge_table(opt, {
            desc = desc,
          })
        end
        local code_action = function()
          vim.cmd.RustLsp('codeAction')
        end
        local hover_action = function()
          vim.cmd.RustLsp { 'hover', 'actions' }
        end
        local hover_range = function()
          vim.cmd.RustLsp { 'hover', 'range' }
        end
        local open_cargo = function()
          vim.cmd.RustLsp { 'openCargo' }
        end
        local view_syntax_tree = function()
          vim.cmd.RustLsp { 'syntaxTree' }
        end
        local debug = function()
          vim.cmd.RustLsp('debuggables')
        end
        -- 需要dot
        -- local view_crate_graph = function()
        --  vim.cmd.RustLsp { 'crateGraph', '[backend]', '[output]' }
        -- end
        local keymaps = {
          { 'n', '<leader>ca', code_action,      merge_opt('Rust Code Action') },
          { 'n', 'K',          hover_action,     merge_opt('Rust Hover Actions') },
          { 'n', '<leader>cc', open_cargo,       merge_opt('Open Cargo Config File') },
          { 'n', '<leader>cs', view_syntax_tree, merge_opt('View Syntax Tree') },
          -- { 'n', '<leader>cd', debug, merge_opt('Debug Rust Project') },
          -- { 'n', '<leader>cg', view_crate_graph, merge_opt('Rust Hover Actions') },
          -- { 'v', '<leader>k', hover_range, merge_opt('Rust Hover Range') },
        }
        tools.set_keymap(keymaps)
      end,
      default_settings = {
        ['rust-analyzer'] = {}
      },
      settings = function(project_root)
        local ra = require('rustaceanvim.config.server')
        return ra.load_rust_analyzer_settings(project_root, {
          settings_file_pattern = 'rust-analyzer.json'
        })
      end,
    },
    -- nvim-dap 配置
    dap = {
      adapter = {
        type = 'server',
        port = '${port}',
        host = '127.0.0.1',
        executable = {
          command = adapters.codelldb_path,
          args = {
            "--port",
            "${port}"
          }
        }
      }
    }
  }
end
