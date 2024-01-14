return {
  'f-person/git-blame.nvim',
  config = function()
    vim.g['gitblame_message_template'] = '<summary> • <committer-date> • <committer>'
    vim.g['gitblame_date_format'] = '%r (%Y-%m-%d %H:%M:%S)'
    require('gitblame').setup {
      enabled = false,
    }
  end,
}
