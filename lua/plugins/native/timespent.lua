return {
  "quentingruber/timespent.nvim",
  cmd = { "ShowTimeSpent", "ExportTimeSpent" },
  keys = {
    { "<leader>ts", "<cmd>:ShowTimeSpent<cr>", mode = { "n" }, desc = "编码时间花费记录" },
    { "<leader>te", "<cmd>:ExportTimeSpent<cr>", mode = { "n" }, desc = "编码时间花费记录导出" },
  },
}
