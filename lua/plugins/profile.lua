return {
  'stevearc/profile.nvim',
  config = function()
    local utils = require 'utils'
    local should_profile = os.getenv 'NVIM_PROFILE'
    if should_profile then
      require('profile').instrument_autocmds()
      if should_profile:lower():match '^start' then
        require('profile').start '*'
      else
        require('profile').instrument '*'
      end
    end

    local function toggle_profile()
      local prof = require 'profile'
      if prof.is_recording() then
        prof.stop()
        vim.ui.input({ prompt = 'Save profile to:', completion = 'file', default = 'profile.json' }, function(filename)
          if filename then
            prof.export(filename)
            vim.notify(string.format('Wrote %s', filename))
          end
        end)
      else
        prof.start '*'
      end
    end
    local keymaps = {
      { 'n', '<f1>', toggle_profile, { desc = '开始/结束profile' } }
    }
    utils.set_keymap(keymaps)
  end,
  cond = function()
    local should_profile = os.getenv 'NVIM_PROFILE'
    if should_profile then
      return true
    end
  end
}
