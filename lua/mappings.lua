require "nvchad.mappings"

-- 删除内置快捷键
local del = vim.keymap.del

del("n", "<leader>e")
del("n", "<leader>fm")
del("n", "<leader>fa")
del("n", "<leader>fb")
del("n", "<leader>ff")
del("n", "<leader>fh")
del("n", "<leader>fo")
del("n", "<leader>fw")
del("n", "<leader>fz")
del("n", "<C-n>")
del("n", "<leader>v")
del("n", "<leader>h")
del("i", "<C-h>")
del("i", "<C-j>")
del("i", "<C-k>")
del("i", "<C-l>")
del("n", "<C-h>")
del("n", "<C-j>")
del("n", "<C-k>")
del("n", "<C-l>")
del("i", "<C-e>")
del("i", "<C-b>")
del("n", "<C-c>")
del("n", "<C-s>")
del("n", "<leader>wk")
del("n", "<leader>wK")
del({ "n", "v" }, "<leader>/")
del("n", "<leader>b")
del("n", "<C-w><C-d>")
del("n", "<C-w>d")
del("n", "<leader>ch")
del("n", "<leader>th")

-- 增加自定义快捷键

local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("n", "sh", "<C-w>h", { desc = "切换到左侧窗口" })
map("n", "sj", "<C-w>j", { desc = "切换到下方窗口" })
map("n", "sk", "<C-w>k", { desc = "切换到上方窗口" })
map("n", "sl", "<C-w>l", { desc = "切换到右侧窗口" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("i", "<A-j>", "<Down>", { desc = "光标下移" })
map("i", "<A-k>", "<Up>", { desc = "光标上移" })
map("i", "<A-h>", "<Left>", { desc = "光标左移" })
map("i", "<A-l>", "<Right>", { desc = "光标右移" })

map("n", "<A-j>", "ddp", { desc = "整行下移" })
map("n", "<A-k>", "dd2kp", { desc = "整行上移" })

map("i", "<A-p>", "<C-r>+", { desc = "插入模式粘贴系统粘贴板" })
map("i", "<A-0>", '<c-r>"', { desc = "插入模式粘贴默认register内容" })
map({ "n", "v" }, "<A-p>", '"+p', { desc = "Normal粘贴系统粘贴板" })
map({ "n", "v" }, "<A-0>", '""p', { desc = "Normal粘贴默认register内容" })

map({ "v", "o", "n" }, "H", "^", { desc = "移动光标到头部" })
map({ "v", "o", "n" }, "L", "$", { desc = "移动光标到尾部" })

map("n", "<A-v>", "<C-v>", { desc = "进入 Multiple Visual 模式" })
map("n", "gb", "<C-o>", { desc = "返回上一步" })

map("n", "<A-\\>", "<CMD>split<CR>", { desc = "垂直拆分窗口" })
map("n", "\\", "<CMD>vsplit<CR>", { desc = "水平拆分窗口" })
map("n", "<A-x>", "<C-w>q", { desc = "关闭窗口" })

map("v", "<", "<gv", { desc = "避免visual模式下处理缩进之后，选区丢失" })
map("v", ">", ">gv", { desc = "避免visual模式下处理缩进之后，选区丢失" })
map("v", "p", '"_dP', { desc = "避免visual模式下粘贴影响正常yank的register" })
map("n", "x", '"_x', { desc = "避免x删除的内容影响默认register" })

map("v", "<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "替换当前选择的文本(逐个确认)" })
map("v", "<A-c>", '"+y', { desc = "复制选中内容到系统粘贴板" })

map("n", "<leader>e", "<CMD>Oil<CR>", { desc = "打开文件系统" })

map("n", "ss", "<cmd>HopChar2<cr>", { desc = "单个字符搜索" })
map("n", "sc", "<cmd>HopChar1<cr>", { desc = "单个字符搜索" })
map("n", "sw", "<cmd>HopWord<cr>", { desc = "单词搜索" })
map("n", "sp", "<cmd>HopPattern<cr>", { desc = "正则搜索" })

map("n", "<leader>gl", "<cmd>GitBlameToggle<cr>", { desc = "显示/隐藏Git Blame" })

map("n", "<TAB>", "<cmd>BufferLineCycleNext<cr>", { desc = "切换下一个Tab签" })
map("n", "<A-TAB>", "<cmd>BufferLineCyclePrev<cr>", { desc = "切换上一个Tab签" })
map("n", "=", "<cmd>BufferLinePick<cr>", { desc = "选择跳转指定Tab签" })
map("n", "-", "<cmd>BufferLinePickClose<cr>", { desc = "选择关闭指定Tab签" })
map("n", "<leader>-", "<cmd>BufferLineCloseOthers<CR>", { desc = "关闭其它Tab签" })

map("n", "<leader>ww", "<cmd>lua require('spectre').toggle()<CR>", { desc = "显示/隐藏Spectre" })
map(
  "n",
  "<leader>wc",
  "<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
  { desc = "搜索当前单词(spectre)" }
)
map(
  "n",
  "<leader>wb",
  "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>",
  { desc = "只在当前Buffer搜索" }
)

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "vsp", size = 0.5 }
end, { desc = "打开Terminal" })

-- fzf-lua
map("n", "<leader><space>", '<cmd>lua require("fzf-lua").files()<CR>', { desc = "FZF搜索文件" })
map("n", "<leader>b", '<cmd>lua require("fzf-lua").buffers()<CR>', { desc = "FZF搜索当前打开的Buffers" })
map("n", "<leader>,", '<cmd>lua require("fzf-lua").resume()<CR>', { desc = "还原FZF上次搜索" })
map("n", "<leader>.", '<cmd>lua require("fzf-lua").live_grep()<CR>', { desc = "FZF搜索字符(整个项目)" })
map(
  "v",
  "<leader>.",
  '<cmd>lua require("fzf-lua").grep_visual()<CR>',
  { desc = "FZF搜索选中的字符(整个项目)" }
)
map(
  "n",
  "<leader>w",
  '<cmd>lua require("fzf-lua").grep_cword()<CR>',
  { desc = "FZF搜索光标下的字母(整个项目)" }
)
map("n", "<leader>/", '<cmd>lua require("fzf-lua").lgrep_curbuf()<CR>', { desc = "FZF搜索字符(当前Buffer)" })
map("n", "<leader>'", '<cmd>lua require("fzf-lua").registers()<CR>', { desc = "FZF搜索registers" })
map(
  "n",
  "<leader>o",
  '<cmd>lua require("fzf-lua").oldfiles({ cwd_only = true })<CR>',
  { desc = "FZF搜索文件历史" }
)
map(
  "n",
  "<leader>gcc",
  '<cmd>lua require("fzf-lua").git_bcommits()<CR>',
  { desc = "FZF搜索提交历史(当前Buffer)" }
)
map(
  "n",
  "<leader>gca",
  '<cmd>lua require("fzf-lua").git_commits()<CR>',
  { desc = "FZF搜索提交历史(整个项目)" }
)
map("n", "<leader>gs", '<cmd>lua require("fzf-lua").git_status()<CR>', { desc = "FZF搜索git status" })
map("n", "<leader>gb", '<cmd>lua require("fzf-lua").git_commits()<CR>', { desc = "FZF搜索git branchs" })
map(
  "n",
  "<leader>lr",
  '<cmd>lua require("fzf-lua").lsp_references({ jump_to_single_result = true, ignore_current_line = true, includeDeclaration = false })<CR>',
  { desc = "FZF搜索references" }
)
map("n", "<leader>li", '<cmd>lua require("fzf-lua").lsp_implementations()<CR>', { desc = "FZF搜索implementations" })
map(
  "n",
  "<leader>ls",
  '<cmd>lua require("fzf-lua").lsp_document_symbols()<CR>',
  { desc = "FZF搜索symbols(当前Buffer)" }
)
map(
  "n",
  "<leader>ld",
  '<cmd>lua require("fzf-lua").diagnostics_document()<CR>',
  { desc = "FZF搜索diagnostics(当前Buffer)" }
)
map("n", "<leader>`", function()
  require("nvchad.themes").open { style = "flat" }
end, { desc = "切换主题" })
