return {
  "mhartington/formatter.nvim",
  lazy = true,
  module = true,
  config = function ()
    local tools = require "tools.tools"
    local formatter = require("formatter")
    local web_format = function ()
      local is_eslint_project = tools.is_eslint_project();
      if is_eslint_project then
        return {
          exe = "eslint_d",
          args = { "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0), "--fix-to-stdout" },
          stdin = true,
        }
      else
        return {
          exe = "tsserver",
          args = { "--stdin", "--stdin-filename", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    end
    local opt = {
      logging = false,
      filetype = {
        typescriptreact = {
          web_format,
        },
        typescript = {
          web_format,
        },
        javascript = {
          web_format,
        },
        javascriptreact = {
          web_format,
        },
        lua = {
          require("formatter.filetypes.lua").stylua,
        }
      }
    }
    formatter.setup(opt)
  end
}
