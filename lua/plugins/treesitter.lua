return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "html",
      "css",
      "jsdoc",
      "scss",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<A-s>",
        node_incremental = "<A-s>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  },
}
