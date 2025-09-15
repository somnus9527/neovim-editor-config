return {
  "Exafunction/windsurf.vim",
  event = "BufEnter",
  config = function()
    local map = LazyVim.safe_keymap_set
    local opts = { expr = true, silent = true }
    map("i", "<C-y>", function()
      return vim.fn["codeium#Accept"]()
    end, opts)
    map("i", "<C-.>", function()
      return vim.fn["codeium#CycleCompletions"](1)
    end, opts)
    map("i", "<C-,>", function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end, opts)
    map("i", "<C-x>", function()
      return vim.fn["codeium#Clear"]()
    end, opts)
    map("i", "<C-/>", function()
      return vim.fn["codeium#Complete"]()
    end, opts)
    map("i", "<C-[>", function()
      return vim.fn["codeium#AcceptNextWord"]()
    end, opts)
    map("i", "<C-]>", function()
      return vim.fn["codeium#AcceptNextLine"]()
    end, opts)
  end,
}
