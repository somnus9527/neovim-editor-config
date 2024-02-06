return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
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
    -- 自定义样式
    vim.api.nvim_set_hl(0, 'PmenuSel', { bg = '#282C34', fg = 'NONE' })
    vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#C5CDD9', bg = '#22252A' })

    vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { fg = '#7E8294', bg = 'NONE', strikethrough = true })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { fg = '#82AAFF', bg = 'NONE', bold = true })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { fg = '#82AAFF', bg = 'NONE', bold = true })
    vim.api.nvim_set_hl(0, 'CmpItemMenu', { fg = '#C792EA', bg = 'NONE', italic = true })

    vim.api.nvim_set_hl(0, 'CmpItemKindField', { fg = '#EED8DA', bg = '#B5585F' })
    vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { fg = '#EED8DA', bg = '#B5585F' })
    vim.api.nvim_set_hl(0, 'CmpItemKindEvent', { fg = '#EED8DA', bg = '#B5585F' })

    vim.api.nvim_set_hl(0, 'CmpItemKindText', { fg = '#C3E88D', bg = '#9FBD73' })
    vim.api.nvim_set_hl(0, 'CmpItemKindEnum', { fg = '#C3E88D', bg = '#9FBD73' })
    vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { fg = '#C3E88D', bg = '#9FBD73' })

    vim.api.nvim_set_hl(0, 'CmpItemKindConstant', { fg = '#FFE082', bg = '#D4BB6C' })
    vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { fg = '#FFE082', bg = '#D4BB6C' })
    vim.api.nvim_set_hl(0, 'CmpItemKindReference', { fg = '#FFE082', bg = '#D4BB6C' })

    vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = '#EADFF0', bg = '#A377BF' })
    vim.api.nvim_set_hl(0, 'CmpItemKindStruct', { fg = '#EADFF0', bg = '#A377BF' })
    vim.api.nvim_set_hl(0, 'CmpItemKindClass', { fg = '#EADFF0', bg = '#A377BF' })
    vim.api.nvim_set_hl(0, 'CmpItemKindModule', { fg = '#EADFF0', bg = '#A377BF' })
    vim.api.nvim_set_hl(0, 'CmpItemKindOperator', { fg = '#EADFF0', bg = '#A377BF' })

    vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { fg = '#C5CDD9', bg = '#7E8294' })
    vim.api.nvim_set_hl(0, 'CmpItemKindFile', { fg = '#C5CDD9', bg = '#7E8294' })

    vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { fg = '#F5EBD9', bg = '#D4A959' })
    vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', { fg = '#F5EBD9', bg = '#D4A959' })
    vim.api.nvim_set_hl(0, 'CmpItemKindFolder', { fg = '#F5EBD9', bg = '#D4A959' })

    vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { fg = '#DDE5F5', bg = '#6C8ED4' })
    vim.api.nvim_set_hl(0, 'CmpItemKindValue', { fg = '#DDE5F5', bg = '#6C8ED4' })
    vim.api.nvim_set_hl(0, 'CmpItemKindEnumMember', { fg = '#DDE5F5', bg = '#6C8ED4' })

    vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { fg = '#D8EEEB', bg = '#58B5A8' })
    vim.api.nvim_set_hl(0, 'CmpItemKindColor', { fg = '#D8EEEB', bg = '#58B5A8' })
    vim.api.nvim_set_hl(0, 'CmpItemKindTypeParameter', { fg = '#D8EEEB', bg = '#58B5A8' })
    -- 自定义样式结束
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
      -- enabled = function()
      --   if vim.api.nvim_buf_get_option(0, 'buftype') == 'TelescopePrompt' then
      --     return false
      --   end
      --   return false
      -- end,
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      -- 这两个table的区别是，先在第一个table里面找，找不到再去第二个table找
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
      }, {
        { name = 'buffer' },
        { name = 'path' },
      }),
      window = {
        completion = {
          winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
          col_offset = -3,
          side_padding = 0,
        },
      },
      formatting = {
        -- format = lspkind.cmp_format {
        --   mode = 'symbol_text',
        --   preset = 'codicons',
        --   symbol_map = icons.kinds,
        --   menu = {
        --     buffer = '[Buffer]',
        --     nvim_lsp = '[LSP]',
        --     path = '[Path]',
        --     nvim_lua = '[Lua]',
        --     cmdline = '[CMD]',
        --   },
        -- },
        -- 排序
        fields = { 'menu', 'abbr', 'kind' },
        -- format = lspkind.cmp_format {
        --   mode = 'text_symbol',
        --   preset = 'codicons',
        --   -- maxwidth = 80,
        --   ellipsis_char = '...',
        --   -- show_labelDetails = true,
        --   before = function(entry, vim_item)
        --     -- 暂时没有修改，有修改可以放在这, 参考下面的注释
        --     return vim_item
        --   end,
        -- },
        format = function(entry, vim_item)
          local kind = lspkind.cmp_format { mode = 'symbol_text', maxwidth = 50 }(entry, vim_item)
          local strings = vim.split(kind.kind, '%s', { trimempty = true })
          local icon = icons.Menu[entry.source.name]
          kind.kind = ' ' .. (strings[1] or '') .. ' ' .. '(' .. (strings[2] or '') .. ')'
          kind.menu = '[' .. icon .. ']'
          return kind
          -- local lspkind_ok, lspkind = pcall(require, 'lspkind')
          -- if not lspkind_ok then
          --   -- 设置图标
          --   vim_item.kind = string.format('%s %s', icons.kinds[vim_item.kind], vim_item.kind)
          --   vim_item.menu = ({
          --     buffer = '[Buffer]',
          --     nvim_lsp = '[LSP]',
          --     path = '[Path]',
          --     nvim_lua = '[Lua]',
          --     cmdline = '[CMD]',
          --     luasnip = "[LuaSnip]",
          --   })[entry.source.name]
          --   return vim_item
          -- else
          --   return lspkind.cmp_format()(entry, vim_item)
          -- end
        end,
      },
      experimental = {
        ghost_text = {
          hl_group = 'LspCodeLens',
        },
      },
      mapping = {
        ['<M-n>'] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert }, { 'i', 'c' }),
        ['<M-m>'] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert }, { 'i', 'c' }),
        ['<M-[>'] = cmp.mapping.scroll_docs(-4),
        ['<M-]>'] = cmp.mapping.scroll_docs(4),
        ['<M-c>'] = cmp.mapping.complete(),
        ['<M-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping(cmp.mapping.confirm { select = true }, { 'i' }),
        ['`'] = cmp.mapping(cmp.mapping.confirm { select = true }, { 'c' }),
        -- ['<CR>'] = cmp.mapping {
        --   i = function(fallback)
        --     if cmp.visible() and cmp.get_active_entry() then
        --       cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        --     else
        --       fallback()
        --     end
        --   end,
        --   s = cmp.mapping.confirm { select = true },
        --   c = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
        -- },
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
      mapping = cmp.mapping.preset.cmdline {},
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
    cmp.setup.filetype('lua', {
      sources = cmp.config.sources({
        { name = 'luasnip' },
      }, {
        { name = 'nvim_lua' },
        { name = 'buffer' },
        { name = 'path' },
      }),
    })
    cmp.setup.filetype('json', {
      sources = cmp.config.sources({
        { name = 'npm' },
      }, {
        { name = 'path' },
      }),
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
