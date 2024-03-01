-- 好像另外起了一个没有代理的终端，所以用不起来，暂时禁用
return {
  'jackMort/ChatGPT.nvim',
  cmd = "ChatGPT",
  enabled = false,
  config = function()
    local chatgpt = require 'chatgpt'
    local tools = require 'tools.tools'
    local const = require 'tools.const'
    local opts = tools.load_conf()
    vim.g.gpt_api_key = opts.default.gpt_api_key
    chatgpt.setup({
      api_key_cmd = 'gpg -d ' .. tools.path.conf_root() .. const.path_separator .. 'chatgpt_api_key.txt.gpg'
    })
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
}
