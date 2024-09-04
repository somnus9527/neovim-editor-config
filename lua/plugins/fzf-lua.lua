return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local fzf = require 'fzf-lua'
    local tools = require 'tools.tools'
    local opts = {
      file_ignore_patterns = { 'node_modules/', 'dist/', '.vscode/' },
      winopts = {
        width = 0.9,
        height = 0.9,
        backdrop = 80,
        preview = {
          hidden = 'hidden',
        },
        on_create = function ()
          local keymaps = {
            { 't', '<M-n>', '<Down>', { desc = '下移一个选项' } },
            { 't', '<M-m>', '<Up>', { desc = '上移一个选项' } },
          }
          tools.set_keymap(keymaps)
        end
      },
      files = {
        git_icons = false,
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git --no-ignore]],
      },
      keymap = {
        -- 这个插件不太一样, 不定义也会禁用掉快捷键,所以先全量拷过来
        builtin = {
          -- neovim `:tmap` mappings for the fzf win
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          -- Only valid with the 'builtin' previewer
          ['<F3>'] = 'toggle-preview-wrap',
          ['<F4>'] = 'toggle-preview',
          -- Rotate preview clockwise/counter-clockwise
          ['<F5>'] = 'toggle-preview-ccw',
          ['<F6>'] = 'toggle-preview-cw',
          ['<S-down>'] = 'preview-page-down',
          ['<S-up>'] = 'preview-page-up',
          ['<S-left>'] = 'preview-page-reset',
          -- 自定义
          ['<alt-e>'] = 'abort',
        },
        fzf = {
          -- fzf '--bind=' options
          ['alt-e'] = 'abort', -- 自定义
          ['ctrl-u'] = 'unix-line-discard',
          ['ctrl-f'] = 'half-page-down',
          ['ctrl-b'] = 'half-page-up',
          ['ctrl-a'] = 'beginning-of-line',
          ['ctrl-e'] = 'end-of-line',
          ['alt-a'] = 'toggle-all',
          -- Only valid with fzf previewers (bat/cat/git/etc)
          ['f3'] = 'toggle-preview-wrap',
          ['f4'] = 'toggle-preview',
          ['shift-down'] = 'preview-page-down',
          ['shift-up'] = 'preview-page-up',
        },
      },
    }
    fzf.setup(opts)

    local keymaps = {
      {
        'n',
        '<leader><leader>',
        '<cmd>lua require("fzf-lua").files()<CR>',
        { desc = 'FZF搜索文件' },
      },
      { 'n', '<leader>,', '<cmd>lua require("fzf-lua").resume()<CR>', { desc = '还原FZF上次搜索' } },
      { 'n', '<leader>b', '<cmd>lua require("fzf-lua").buffers()<CR>', { desc = 'FZF搜索当前打开的Buffers' } },
      { 'n', '<leader>.', '<cmd>lua require("fzf-lua").live_grep()<CR>', { desc = 'FZF搜索字符(整个项目)' } },
      {
        'v',
        '<leader>.',
        '<cmd>lua require("fzf-lua").grep_visual()<CR>',
        { desc = 'FZF搜索选中的字符(整个项目)' },
      },
      {
        'n',
        '<leader>;',
        '<cmd>lua require("fzf-lua").grep_cword()<CR>',
        { desc = 'FZF搜索光标下的字母(整个项目)' },
      },
      {
        'n',
        '<leader>/',
        '<cmd>lua require("fzf-lua").lgrep_curbuf()<CR>',
        { desc = 'FZF搜索字符(当前Buffer)' },
      },
      { 'n', "<leader>'", '<cmd>lua require("fzf-lua").registers()<CR>', { desc = 'FZF搜索registers' } },
      {
        'n',
        '<leader>o',
        '<cmd>lua require("fzf-lua").oldfiles({ cwd_only = true })<CR>',
        { desc = 'FZF搜索文件历史' },
      },
      { 'n', '<leader>`', '<cmd>lua require("fzf-lua").colorschemes()<CR>', { desc = 'FZF搜索主题' } },
      {
        'n',
        '<leader>gcc',
        '<cmd>lua require("fzf-lua").git_bcommits()<CR>',
        { desc = 'FZF搜索提交历史(当前Buffer)' },
      },
      {
        'n',
        '<leader>gca',
        '<cmd>lua require("fzf-lua").git_commits()<CR>',
        { desc = 'FZF搜索提交历史(整个项目)' },
      },
      { 'n', '<leader>gs', '<cmd>lua require("fzf-lua").git_status()<CR>', { desc = 'FZF搜索git status' } },
      { 'n', '<leader>gb', '<cmd>lua require("fzf-lua").git_commits()<CR>', { desc = 'FZF搜索git branchs' } },
      {
        'n',
        '<leader>lr',
        '<cmd>lua require("fzf-lua").lsp_references({ jump_to_single_result = true, ignore_current_line = true, includeDeclaration = false })<CR>',
        { desc = 'FZF搜索references' },
      },
      {
        'n',
        '<leader>li',
        '<cmd>lua require("fzf-lua").lsp_implementations()<CR>',
        { desc = 'FZF搜索implementations' },
      },
      {
        'n',
        '<leader>ls',
        '<cmd>lua require("fzf-lua").lsp_document_symbols()<CR>',
        { desc = 'FZF搜索symbols(当前Buffer)' },
      },
      {
        'n',
        '<leader>ld',
        '<cmd>lua require("fzf-lua").diagnostics_document()<CR>',
        { desc = 'FZF搜索diagnostics(当前Buffer)' },
      },
      -- TODO: 需要把todo-comments的搜索注入到fzf-lua中
      -- {
      --   'n',
      --   '<leader>lt',
      --   ':lua require("tools.tools").show_todo()<CR>',
      --   { desc = '搜索所以TODO' }
      -- }
    }
    tools.set_keymap(keymaps)
  end,
}
