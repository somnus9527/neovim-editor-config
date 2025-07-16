return {
  "zhisme/copy_with_context.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("copy_with_context").setup({
      mappings = {
        relative = "<leader>cy",
        absolute = "<leader>cY",
      },
      trim_lines = false,
      context_format = "# %s:%s",
    })
  end,
}
