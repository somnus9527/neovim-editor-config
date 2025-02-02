-- LSP keymaps
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- change a keymap
    -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
    -- disable a keymap
    keys[#keys + 1] = { "<a-n>", false }
    keys[#keys + 1] = { "<a-p>", false }
    -- add a keymap
    -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
    keys[#keys + 1] = { "ge", "<cmd>lua vim.diagnostic.open_float()<CR>" }
    LazyVim.extend(opts, "setup", {
      -- 解决clangd offset encoding问题
      clangd = function(_, copts)
        copts.capabilities.offsetEncoding = { "utf-16" }
      end,
      eslint = function()
        -- 解决eslint-plugin-prettier问题
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "vtsls" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    })
  end,
}
