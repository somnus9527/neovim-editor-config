return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local icons = require("config.icons")
    local symbol_def = {
      add = { text = icons.git.added },
      change = { text = icons.git.modified },
      delete = { text = icons.git.removed },
      topdelete = { text = icons.git.topdelete },
      changedelete = { text = icons.git.changedelete },
      untracked = { text = icons.git.untracked },
    }
    LazyVim.extend(opts, "signs", symbol_def)
    LazyVim.extend(opts, "signs_staged", symbol_def)
  end,
}
