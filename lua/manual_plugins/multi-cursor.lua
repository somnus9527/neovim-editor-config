return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = { 'BufNewFile', 'BufReadPre' },
  config = function()
    vim.g.VM_default_mappings = 0 -- 使用默认映射
    vim.g.VM_maps = {
      ["Select All"] = "<C-a>", -- 一次选中所有匹配的单词
      ["Find Under"] = "<C-n>", -- 开启多光标模式
      ["Find Subword Under"] = "<C-n>", -- 搜索子词
      ["Add Cursor Down"] = "<C-Down>", -- 向下添加光标
      ["Add Cursor Up"] = "<C-Up>", -- 向上添加光标
    }
  end,
}
