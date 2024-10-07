return {
  "ibhagwan/fzf-lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local fzf = require "fzf-lua"
    local tools = require "tools.tools"
    local opts = {
      file_ignore_patterns = { "node_modules/", "dist/", ".vscode/" },
      winopts = {
        width = 0.9,
        height = 0.9,
        backdrop = 80,
        preview = {
          hidden = "hidden",
        },
        on_create = function()
          local keymaps = {
            { "t", "<M-n>", "<Down>", { desc = "下移一个选项" } },
            { "t", "<M-m>", "<Up>", { desc = "上移一个选项" } },
          }
          tools.set_keymap(keymaps)
        end,
      },
      files = {
        git_icons = false,
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git --no-ignore]],
      },
      keymap = {
        -- 这个插件不太一样, 不定义也会禁用掉快捷键,所以先全量拷过来
        builtin = {
          -- neovim `:tmap` mappings for the fzf win
          ["<F1>"] = "toggle-help",
          ["<F2>"] = "toggle-fullscreen",
          -- Only valid with the 'builtin' previewer
          ["<F3>"] = "toggle-preview-wrap",
          ["<F4>"] = "toggle-preview",
          -- Rotate preview clockwise/counter-clockwise
          ["<F5>"] = "toggle-preview-ccw",
          ["<F6>"] = "toggle-preview-cw",
          ["<S-down>"] = "preview-page-down",
          ["<S-up>"] = "preview-page-up",
          ["<S-left>"] = "preview-page-reset",
          -- 自定义
          ["<alt-e>"] = "abort",
        },
        fzf = {
          -- fzf '--bind=' options
          ["alt-e"] = "abort", -- 自定义
          ["ctrl-u"] = "unix-line-discard",
          ["ctrl-f"] = "half-page-down",
          ["ctrl-b"] = "half-page-up",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
          -- Only valid with fzf previewers (bat/cat/git/etc)
          ["f3"] = "toggle-preview-wrap",
          ["f4"] = "toggle-preview",
          ["shift-down"] = "preview-page-down",
          ["shift-up"] = "preview-page-up",
        },
      },
    }
    fzf.setup(opts)
  end,
}
