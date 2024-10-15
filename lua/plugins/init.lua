return {

  -- 禁用部分插件
  { "folke/which-key.nvim", enabled = false },
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "lukas-reineke/indent-blankline.nvim", enabled = false },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, conf)
      conf.ensure_installed = {
        "html",
        "css",
        "bash",
        "angular",
        "dot",
        "gitcommit",
        "gitignore",
        "ini",
        "scss",
        "sql",
        "dockerfile",
        "editorconfig",
        "nginx",
        "json",
        "jsdoc",
        "jsonc",
        "javascript",
        "markdown",
        "rust",
        "svelte",
        "toml",
        "tsx",
        "vue",
        "xml",
        "yaml",
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
        callback = function()
          vim.treesitter.start(nil, "angular")
        end,
      })
      return conf
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>f",
        function()
          require("conform").format { async = true }
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, conf)
      local cmp = require "cmp"
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end
      conf.mapping = {
        ["<A-n>"] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert }, { "i", "c" }),
        ["<A-m>"] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert }, { "i", "c" }),
        ["<A-[>"] = cmp.mapping.scroll_docs(-4),
        ["<A-]>"] = cmp.mapping.scroll_docs(4),
        ["<A-c>"] = cmp.mapping.complete(),
        ["<A-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping(cmp.mapping.confirm { select = true }, { "i" }),
        ["`"] = cmp.mapping(cmp.mapping.confirm { select = true }, { "c" }),
        ["<S-CR>"] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() and has_words_before() then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
          elseif cmp.visible() then
            cmp.select_next_item()
          -- elseif has_words_before() then
          --   cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      }
      return conf
    end,
  },
}
