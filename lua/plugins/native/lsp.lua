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
    keys[#keys + 1] = { "K", false }
    -- add a keymap
    -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
    keys[#keys + 1] = { "ge", "<cmd>lua vim.diagnostic.open_float()<CR>" }
    keys[#keys + 1] = {
      "K",
      function()
        local hover = vim.lsp.buf_request_sync(0, "textDocument/hover", vim.lsp.util.make_position_params(0, "utf-8"))
        if not hover or vim.tbl_isempty(hover) then
          return
        end
        vim.lsp.buf.hover()
      end,
    }
    -- LazyVim.extend(opts.servers, "angularls", {
    --   cmd = {
    --     "ngserver",
    --     "--ngProbeLocations",
    --     vim.loop.cwd() .. "/node_modules",
    --     "--tsProbeLocations",
    --     vim.loop.cwd() .. "/node_modules",
    --     "--includeCompletionsWithSnippetText",
    --     "--includeAutomaticOptionalChainCompletions",
    --   },
    --   on_new_config = function(new_config, _)
    --     new_config.cmd = {
    --       "ngserver",
    --       "--ngProbeLocations",
    --       new_config.root_dir .. "/node_modules",
    --       "--tsProbeLocations",
    --       new_config.root_dir .. "/node_modules",
    --       "--includeCompletionsWithSnippetText",
    --       "--includeAutomaticOptionalChainCompletions",
    --     }
    --   end,
    --   root_dir = require("lspconfig.util").root_pattern("angular.json", "project.json"),
    --   filetypes = { "typescript", "html" },
    -- })
    LazyVim.extend(opts.servers, "cssls", {});
    LazyVim.extend(opts.servers, "cssmodules_ls", {});
    LazyVim.extend(opts.servers, "html", {});
    -- print(opts.servers.angularls)
    LazyVim.extend(opts, "setup", {
      -- 解决clangd offset encoding问题
      clangd = function(_, copts)
        copts.capabilities.offsetEncoding = { "utf-16" }
      end,
      cssls = function(_, copts)
        copts.settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
        }
        copts.on_attach = function(client)
          client.server_capabilities.foldingRangeProvider = false
        end
      end,
      -- angularls = function()
      --   vim.notify("[angularls] forcibly disabled", vim.log.levels.WARN)
      --   return true -- 返回 true 阻止 lspconfig setup 被调用
      -- end,
      -- angularls = function()
      --   LazyVim.lsp.on_attach(function(client)
      --     -- Optional: Disable rename due to duplicated rename popup
      --     client.server_capabilities.renameProvider = false
      --   end, "angularls")
      -- end,
      -- eslint = function()
      --   -- 解决eslint-plugin-prettier问题
      --   require("lazyvim.util").lsp.on_attach(function(client)
      --     if client.name == "eslint" then
      --       client.server_capabilities.documentFormattingProvider = true
      --     elseif client.name == "vtsls" then
      --       client.server_capabilities.documentFormattingProvider = false
      --     end
      --   end)
      -- end,
    })
  end,
}
