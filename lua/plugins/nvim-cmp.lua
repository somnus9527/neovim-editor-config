return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'L3MON4D3/LuaSnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'David-Kunz/cmp-npm',
    'hrsh7th/cmp-nvim-lua',
    'onsails/lspkind.nvim',
  },
  config = function()
    local luasnip = require 'luasnip'
    local lspkind = require 'lspkind'
    local icons = require 'configs.icons'
    local cmp = require 'cmp'
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
    end
    local opt = {
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      -- snippet = {
      --   expand = function(args)
      --     luasnip.lsp_expand(args.body)
      --   end,
      -- },
      sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'npm' },
        { name = 'nvim_lua' },
        { name = 'cmdline' },
      },
      formatting = {
        format = lspkind.cmp_format {
          mode = 'symbol_text',
          preset = 'codicons',
          symbol_map = icons.kinds,
        },
      },
      experimental = {
        ghost_text = {
          hl_group = 'LspCodeLens',
        },
      },
      mapping = cmp.mapping.preset.insert {
        ['<M-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ['<M-m>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ['<M-[>'] = cmp.mapping.scroll_docs(-4),
        ['<M-]>'] = cmp.mapping.scroll_docs(4),
        ['<M-c>'] = cmp.mapping.complete(),
        ['<M-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm { select = true },
        ['<S-CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
    }
    cmp.setup(opt)
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources {
        { name = 'cmdline' },
        { name = 'path' },
      },
    })
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })
    -- cmp.setup.cmdline(':', {
    --   mapping = cmp.mapping.preset.cmdline(),
    --   sources = cmp.config.sources({
    --     { name = 'path' },
    --   }, {
    --     { name = 'cmdline' },
    --   }),
    -- })
  end,
}
