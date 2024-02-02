return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewFileHistory',
    'DiffviewOpen',
  },
  config = function()
    local diff = require 'diffview'
    local actions = require 'diffview.actions'
    local desc_prefix = '[Diffview] '
    local merge_tool_prefix = '(Merge-Tools) '
    local opts = {
      keymaps = {
        -- disable_defaults = true,
        view = {
          -- { 'n', '<leader>f', actions.focus_files, { desc = desc_prefix .. '聚焦到文件系统' } },
          { 'n', '<leader>e', actions.toggle_files, { desc = desc_prefix .. '打开/关闭文件系统' } },
          {
            'n',
            '[c',
            actions.prev_conflict,
            { desc = desc_prefix .. merge_tool_prefix .. '跳到上一个Conflict的地方' },
          },
          {
            'n',
            ']c',
            actions.next_conflict,
            { desc = desc_prefix .. merge_tool_prefix .. '跳到下一个Conflict的地方' },
          },
          {
            'n',
            '<leader>co',
            actions.conflict_choose 'ours',
            { desc = desc_prefix .. merge_tool_prefix .. '选择本地版本应用到冲突处' },
          },
          {
            'n',
            '<leader>ct',
            actions.conflict_choose 'theirs',
            { desc = desc_prefix .. merge_tool_prefix .. '选择远程分支版本应用到冲突处' },
          },
          {
            'n',
            '<leader>cb',
            actions.conflict_choose 'base',
            { desc = desc_prefix .. merge_tool_prefix .. '选择Base版本应用到冲突处' },
          },
          {
            'n',
            '<leader>ca',
            actions.conflict_choose 'all',
            { desc = desc_prefix .. merge_tool_prefix .. '选择所有版本应用到冲突处' },
          },
          {
            'n',
            '<leader>cx',
            actions.conflict_choose 'none',
            { desc = desc_prefix .. merge_tool_prefix .. '删除冲突' },
          },
        },
        file_panel = {
          { 'n', '-', actions.toggle_stage_entry, { desc = 'Stage/Unstage当前文件' } },
          { 'n', '=', actions.stage_all, { desc = 'Stage全部文件' } },
          { 'n', '+', actions.unstage_all, { desc = 'Unstage全部文件' } },
          -- { 'n', '<leader>f', actions.focus_files, { desc = desc_prefix .. '聚焦到文件系统' } },
          { 'n', '<leader>e', actions.toggle_files, { desc = desc_prefix .. '打开/关闭文件系统' } },
          {
            'n',
            '[c',
            actions.prev_conflict,
            { desc = desc_prefix .. '跳到上一个Conflict的地方' },
          },
          {
            'n',
            ']c',
            actions.next_conflict,
            { desc = desc_prefix .. '跳到下一个Conflict的地方' },
          },
          { 'n', '<C-n>', actions.scroll_view(0.25), { desc = '往下翻页' } },
          { 'n', '<C-m>', actions.scroll_view(-0.25), { desc = '往上翻页' } },
        },
        file_history_panel = {
          -- { 'n', '<leader>f', actions.focus_files, { desc = desc_prefix .. '聚焦到文件系统' } },
          { 'n', '<leader>e', actions.toggle_files, { desc = desc_prefix .. '打开/关闭文件系统' } },
          { 'n', '<C-n>', actions.scroll_view(0.25), { desc = '往下翻页' } },
          { 'n', '<C-m>', actions.scroll_view(-0.25), { desc = '往上翻页' } },
        },
      },
    }
    diff.setup(opts)
  end,
}
