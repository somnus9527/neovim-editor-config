-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local del = vim.keymap.del
local map = LazyVim.safe_keymap_set
if not vim.g.vscode then
  -- 删除不需要的快捷键配置
  del("i", "<A-j>")
  del("i", "<A-k>")
  del("n", "<leader>|")
  -- del("n", "<C-h>")
  -- del("n", "<C-j>")
  -- del("n", "<C-k>")
  -- del("n", "<C-l>")
  del("n", "<S-h>")
  del("n", "[b")
  del("n", "<S-l>")
  del("n", "]b")
  del({ "n", "v" }, "<leader>cf")
  -- del("n", "<leader>.")
  del("n", "<leader>bb")
  del("n", "<leader>be")
  del("n", "<leader>bl")
  del("n", "<leader>`")
  del("n", "<leader>bd")
  del("n", "<leader>bo")
  del("n", "<leader>bD")
  del("n", "<leader>ft")
  del("n", "<leader>fT")
  del("n", "<leader>l")
  del({ "n", "t" }, "<C-_>")
  del({ "n", "t" }, "<C-/>")
end
if vim.g.vscode then
  local vscode = require("vscode")
  map("v", "p", '"_dP', { desc = "避免visual模式下粘贴影响正常yank的register" })
  map("n", "x", '"_x', { desc = "避免x删除的内容影响默认register" })
  map("n", "za", function()
    vscode.action("editor.toggleFold")
  end, { desc = "Toggle Fold" })
  map("n", "zc", function()
    vscode.action("editor.foldLevel1")
  end, { desc = "折叠第一层" })
  map("n", "zr", function()
    vscode.action("editor.foldAll")
  end, { desc = "折叠" })
  map("n", "zR", function()
    vscode.action("editor.unfoldAll")
  end, { desc = "折叠" })
  -- 不生效，但是直接按<C-o>就可以，感觉又是vscode或者vscode-neovim干了什么。。。
  -- map("n", "gb", "<Cmd>normal! <C-o><CR>", { desc = "回到上一步" })
  -- operator-pending mode
  local operator_pending_opts = { noremap = true }
  map("o", "(", "i(", operator_pending_opts)
  map("o", ")", "a(", operator_pending_opts)
  map("o", "[", "i[", operator_pending_opts)
  map("o", "]", "a[", operator_pending_opts)
  map("o", "<", "i<", operator_pending_opts)
  map("o", ">", "a<", operator_pending_opts)
  map("o", "{", "i{", operator_pending_opts)
  map("o", "}", "a}", operator_pending_opts)
  map("o", "'", "i'", operator_pending_opts)
  map("o", '"', 'i"', operator_pending_opts)
else
  map("i", "jk", "<Esc>", { desc = "退出编辑模式" })
  map("i", "<A-j>", "<Down>", { desc = "光标下移一行" })
  map("i", "<A-k>", "<Up>", { desc = "光标上移一行" })
  map("i", "<A-h>", "<Left>", { desc = "光标左移一格" })
  map("i", "<A-l>", "<Right>", { desc = "光标右移一格" })
  map("n", "<A-TAB>", "<cmd>bprevious<cr>", { desc = "上一个Tab" })
  map("n", "<TAB>", "<cmd>bnext<cr>", { desc = "下一个Tab" })
  map("n", "U", "<C-r>", { desc = "Redo" })
  map({ "v", "o", "n" }, "<S-h>", "^", { desc = "移动光标到行首" })
  map({ "v", "o", "n" }, "<S-l>", "$", { desc = "移动光标到行尾" })
  map("n", "gb", "<C-o>", { desc = "返回" })
  map("v", "<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "替换当前选择的文本(逐个确认)" })
  map("i", "<A-p>", "<C-r>+", { desc = "插入模式粘贴系统剪切板内容" })
  map("i", "<A-0>", '<C-r>"', { desc = "插入模式粘贴默认register中内容" })
  map({ "n", "v" }, "<A-p>", '"+p', { desc = "普通/visual模式粘贴系统剪切板内容" })
  map({ "n", "v" }, "<A-0>", '""p', { desc = "普通/visual模式粘贴默认register中内容" })
  map("v", "p", '"_dP', { desc = "避免visual模式下粘贴影响正常yank的register" })
  map("n", "x", '"_x', { desc = "避免x删除的内容影响默认register" })
  map("v", "<A-c>", '"+y', { desc = "复制选中内容到系统剪切板" })
  map("n", "<leader>\\", "<C-w>v", { desc = "右侧分屏", remap = true })
  map("n", "<leader>|", "<C-w>s", { desc = "底部分屏", remap = true })
  map("n", "<A-x>", "<CMD>q<CR>", { desc = "关闭Window" })
  -- map("n", "sh", "<C-w>h", { desc = "聚焦到左侧窗口" })
  -- map("n", "sj", "<C-w>j", { desc = "聚焦到下侧窗口" })
  -- map("n", "sk", "<C-w>k", { desc = "聚焦到上侧窗口" })
  -- map("n", "sl", "<C-w>l", { desc = "聚焦到右侧窗口" })
  map("n", "<A-->", "<C-w>10<", { desc = "缩小窗口" })
  map("n", "<A-=>", "<C-w>10>", { desc = "放大窗口" })
  if vim.g.neovide then
    map("n", "<A-1>", function()
      local mode = vim.fn.mode()
      if mode:match("[vV\x16]") then
        -- 1. 退出 visual 临时保存
        vim.cmd("normal! <Esc>")
        -- 2. 滚动一页
        vim.cmd("normal! <C-f>")
        -- 3. 恢复选区
        vim.cmd("normal! gv")
      else
        -- 普通模式直接滚动
        vim.cmd("normal! <C-f>")
      end
    end, { desc = "向下滚动" })
    map("n", "<A-2>", function()
      local mode = vim.fn.mode()
      if mode:match("[vV\x16]") then
        -- 1. 退出 visual 临时保存
        vim.cmd("normal! <Esc>")
        -- 2. 滚动一页
        vim.cmd("normal! <C-b>")
        -- 3. 恢复选区
        vim.cmd("normal! gv")
      else
        -- 普通模式直接滚动
        vim.cmd("normal! <C-f>")
      end
    end, { desc = "向上滚动" })
  end
  -- map("n", "<A-1>", "<C-f>", { desc = "向下滚动" })
  -- map("n", "<A-2>", "<C-b>", { desc = "向上滚动" })
  -- map("n", "<A-i>", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "终端" })
  -- map("t", "<A-i>", "<cmd>close<cr>", { desc = "隐藏终端" })
  map("n", "-", function()
    Snacks.bufdelete()
  end, { desc = "删除Tab" })
  map("n", "_", function()
    Snacks.bufdelete.other()
  end, { desc = "删除其它Tab" })
  -- map("n", "<A-1>", "<C-f>", { desc = "往下滚动一屏" })
  -- map("n", "<A-2>", "<C-b>", { desc = "往下滚动一屏" })
  map({ "n", "v" }, "<leader>f", function()
    LazyVim.format({ force = true })
  end, { desc = "Format" })

  map("n", "mm", function()
    local char = vim.fn.getcharstr() -- 获取用户输入的标记字符
    if char:match("[a-z]") then
      char = char:upper() -- 转换为大写（全局标记）
    end
    vim.cmd("normal! m" .. char) -- 设置标记
  end, { noremap = true, silent = true })

  map("n", "mn", function()
    local char = vim.fn.getcharstr() -- 获取用户输入的标记字符
    if char:match("[a-z]") then
      char = char:upper() -- 转换为大写（全局标记）
    end
    vim.cmd("normal! `" .. char) -- 设置标记
  end, { noremap = true, silent = true })

  -- operator-pending mode
  local operator_pending_opts = { noremap = true }
  map("o", "(", "i(", operator_pending_opts)
  map("o", ")", "a(", operator_pending_opts)
  map("o", "[", "i[", operator_pending_opts)
  map("o", "]", "a[", operator_pending_opts)
  map("o", "<", "i<", operator_pending_opts)
  map("o", ">", "a<", operator_pending_opts)
  map("o", "{", "i{", operator_pending_opts)
  map("o", "}", "a}", operator_pending_opts)
  map("o", "'", "i'", operator_pending_opts)
  map("o", '"', 'i"', operator_pending_opts)
end
