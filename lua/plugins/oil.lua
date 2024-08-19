return {
  'stevearc/oil.nvim',
  cmd = "Oil",
  opts = {
    delete_to_trash = true,
    watch_for_changes = true,
    keymaps = {
      ["?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["`"] = "actions.select",
      ["gg"] = "actions.preview",
      ["<leader>e"] = "actions.close",
      ["gr"] = "actions.refresh",
      ["-"] = "actions.parent",
      [","] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["gc"] = { "actions.cd", opts = { scope = "tab" }, desc = "cd到指定文件夹" },
      ["go"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
    },
    use_default_keymaps = false,
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, bufnr)
        return name == '.DS_Store'
      end,
    }
  },
  dependencies = {
    {
      'nvim-web-devicons',
    }
  }
}
