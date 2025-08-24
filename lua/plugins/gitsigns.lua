return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local gitsigns = require("gitsigns")
    local icons = require("tools.icons").git

    gitsigns.setup({
      signs = {
        add = { text = icons.added },
        change = { text = icons.modified },
        delete = { text = icons.removed },
        topdelete = { text = icons.topdelete },
        changedelete = { text = icons.changedelete },
        attach_to_untracked = { text = icons.untracked },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 200,
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = vim.keymap.set

        -- 当前行 Blame
        -- map("n", "<leader>gh", gs.show_line_blame, { buffer = bufnr, desc = "Git Blame 当前行" })
        map("n", "<leader>gb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle 当前行 Blame" })

        -- 快速跳转修改
        map("n", "]]", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(gs.next_hunk)
        end, { expr = true, buffer = bufnr, desc = "下一 Git 修改" })

        map("n", "[[", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(gs.prev_hunk)
        end, { expr = true, buffer = bufnr, desc = "上一 Git 修改" })
      end,
    })
  end
}
