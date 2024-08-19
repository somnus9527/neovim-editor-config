local get_opts = function()
  -- 定义一个自定义高亮组的颜色
  local header = { opts = { hl = 'Operator', position = 'center' }, type = 'text', val = {} }
  local pad = string.rep(' ', 18)
  header.val = {
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    "Somnus9527's Neovim Editor",
    '',
    '我从前单听他讲道理，也糊涂过去;',
    '现在晓得他讲道理的时候，',
    '不但唇边还抹着人油，',
    '而且心里满装着吃人的意思。',
    pad .. '-- <<狂人日记>>',
  }
  local footer = { opts = { hl = 'Special', position = 'center' }, type = 'text', val = {} }
  local lazystats = { type = 'group', val = {} }


  return {
    layout = {
      header,
      { type = 'padding', val = 1 },
      { type = 'padding', val = 1 },
      footer,
      lazystats,
    },
    section = {
      header = header,
      footer = footer,
      lazystats = lazystats,
    },
  }
end

local is_ok, alpha = pcall(require, 'alpha')
if not is_ok then
  return
end

local opts = get_opts()
alpha.setup(opts)

vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('TuoGroup', { clear = false }),
  pattern = 'LazyVimStarted',
  callback = function()
    local stats = require('lazy').stats()
    local footer_val =
      string.format('󱐋 %d/%d plugins loaded in %.3f ms', stats.loaded, stats.count, stats.startuptime)
    opts.section.footer.val = footer_val
    for _, s in ipairs { 'LazyStart', 'LazyDone', 'UIEnter' } do
      table.insert(opts.section.lazystats.val, {
        opts = {
          hl = 'Special',
          position = 'center',
        },
        type = 'text',
        val = string.format('%s %.3f ms', s, stats.times[s]),
      })
    end
    pcall(vim.cmd.AlphaRedraw)
  end,
})
