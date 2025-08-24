return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    name = "gruvbox"
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = { blink_cmp = true },
    },
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
