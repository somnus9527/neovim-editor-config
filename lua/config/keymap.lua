require("tools.global_fn")
local tools = require("tools.tools")

local keymaps = {
	{ { "n", "v" }, "<Esc>", ":lua custom_esc_behavior()<CR>", { desc = "存在高亮先取消高亮" } },
	{
		"i",
		"<Esc>",
		function()
			-- 先退出插入模式
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
			-- 再执行你的自定义逻辑（在普通模式下运行）
			vim.schedule(custom_esc_behavior)
		end,
		{ desc = "存在高亮先取消高亮" },
	},
	{ "i", "jk", "<Esc>", { desc = "退出编辑模式" } },
	{ "n", "U", "<C-r>", { desc = "Redo" } },
	{ { "v", "o", "n" }, "<S-h>", "^", { desc = "移动光标到行首" } },
	{ { "v", "o", "n" }, "<S-l>", "$", { desc = "移动光标到行尾" } },
	{ "i", "<A-h>", "<Left>", { desc = "光标左移一位" } },
	{ "i", "<A-l>", "<Right>", { desc = "光标右移一位" } },
	{ "i", "<A-j>", "<Down>", { desc = "光标下移一位" } },
	{ "i", "<A-k>", "<Up>", { desc = "光标上移一位" } },
	{ "v", "<A-c>", '"+y', { desc = "复制选中内容到系统粘贴板" } },
	{
		{ "i", "s" },
		"<A-s>",
		function()
			local ok, luasnip = pcall(require, "luasnip")
			if ok and luasnip and luasnip.choice_active then
				luasnip.change_choice(1)
			end
		end,
		{ desc = "luasnip的choice node切换" },
	},
	{ "n", "gb", "<C-o>", { desc = "返回上一步" } },
	{ "i", "<A-p>", "<C-r>+", { desc = "插入模式粘贴系统剪切板内容" } },
	{ "i", "<A-0>", '<C-r>"', { desc = "插入模式粘贴默认register中内容" } },
	{
		{ "i", "s" },
		"<TAB>",
		function()
			local ok, luasnip = pcall(require, "luasnip")
			if ok and luasnip and luasnip.jumpable and luasnip.jumpable(1) then
				luasnip.jump(1)
				return
			end
			-- 获取光标前的内容
			local col = vim.fn.col(".") - 1
			local line = vim.fn.getline(".")
			local prefix = line:sub(1, col):match("(%w[%w%d%-%*]*)$") -- emmet 缩写常见结构

			local ok, expanable = pcall(vim.fn["emmet#isExpandable"])
			if ok and expanable and prefix and prefix ~= "" then
				print("expanable")
				vim.fn["emmet#expandAbbr"](0, "")
				-- 光标向右移动 1
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", false)
				return ""
			end
			tools.insert_tab()
			return ""
		end,
		{ desc = "插入模式触发emmet" },
	},
	{ { "n", "v" }, "<A-p>", '"+p', { desc = "普通/visual模式粘贴系统剪切板内容" } },
	{ { "n", "v" }, "<A-0>", '""p', { desc = "普通/visual模式粘贴默认register中内容" } },
	{ "v", "p", '"_dP', { desc = "避免visual模式下粘贴影响正常yank的register" } },
	{ "n", "x", '"_x', { desc = "避免x删除的内容影响默认register" } },
	{ "v", "<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "替换当前选择的文本(逐个确认)" } },
	{ "n", "<leader>\\", "<C-w>v", { desc = "右侧分屏", remap = true } },
	{ "n", "|", "<C-w>s", { desc = "底部分屏", remap = true } },
	{ "n", "<A-x>", "<CMD>q<CR>", { desc = "关闭Window" } },
	{
		"n",
		"<A-->",
		function()
			vim.cmd("vertical resize -10")
		end,
		{ desc = "缩小窗口" },
	},
	{
		"n",
		"<A-=>",
		function()
			vim.cmd("vertical resize +10")
		end,
		{ desc = "放大窗口" },
	},
	{
		"n",
		"<leader>-",
		function()
			vim.cmd("resize -10")
		end,
		{ desc = "纵向缩小窗口" },
	},
	{
		"n",
		"<leader>=",
		function()
			vim.cmd("resize +10")
		end,
		{ desc = "纵向放大窗口" },
	},
	{ "v", "<", "<gv", { desc = "避免visual模式下处理缩进之后，选区丢失" } },
	{ "v", ">", ">gv", { desc = "避免visual模式下处理缩进之后，选区丢失" } },
	{ { "n", "t" }, "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" } },
	{ { "n", "t" }, "<C-j>", "<C-w>j", { desc = "切换到下方窗口" } },
	{ { "n", "t" }, "<C-k>", "<C-w>k", { desc = "切换到上方窗口" } },
	{ { "n", "t" }, "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" } },
	{ "n", "<A-j>", "ddp", { desc = "整行下移" } },
	{ "n", "<A-k>", "dd2kp", { desc = "整行上移" } },
	{ "n", "<leader>n", "<CMD>enew<CR>", { desc = "创建一个新的空白文件" } },
	{ "n", "<A-m>", "%", { desc = "匹配括号" } },

	{ "n", "<leader>ww", "<cmd>lua require('spectre').toggle()<CR>", { desc = "显示/隐藏Spectre" } },
	{
		"n",
		"<leader>wc",
		"<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
		{ desc = "搜索当前单词(spectre)" },
	},
	{
		"n",
		"<leader>wb",
		"<cmd>lua require('spectre').open_file_search({select_word=true})<CR>",
		{ desc = "只在当前Buffer搜索" },
	},
	{
		"n",
		"<leader>gg",
		function()
			local buf = vim.api.nvim_create_buf(false, true)

			-- 创建全屏浮窗
			local win = vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				width = vim.o.columns,
				height = vim.o.lines,
				row = 0,
				col = 0,
				style = "minimal",
				border = "none",
			})

			-- 打开 lazygit
			vim.fn.termopen("lazygit", {
				on_exit = function()
					-- 退出 lazygit 时自动关闭浮窗和 buffer
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_close(win, true)
					end
					if vim.api.nvim_buf_is_valid(buf) then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end,
			})

			-- 自动进入插入模式，直接可用
			vim.cmd("startinsert")
		end,
		{ desc = "打开LazyGit" },
	},

	-- operation pending 配置
	{ "o", "(", "i(" },
	{ "o", ")", "a(" },
	{ "o", "[", "i[" },
	{ "o", "]", "a[" },
	{ "o", "<", "i<" },
	{ "o", ">", "a<" },
	{ "o", "{", "i{" },
	{ "o", "}", "a}" },
	{ "o", "'", "i'" },
	{ "o", '"', 'i"' },
}

tools.set_keymap(keymaps)
