return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>/", false },
    { "<leader>,", "<cmd>Telescope live_grep<cr>", desc = "live_grep workspace" },
    { "<leader>/", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", desc = "live_grep current buffer" },
  }
}
