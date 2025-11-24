return {
	"MattesGroeger/vim-bookmarks",
	cmd = { "BookmarkToggle", "BookmarkAnnotate", "BookmarkClear", "BookmarkShowAll", "BookmarkPrev", "BookmarkNext" },
	keys = {
		{ "mm", "<Plug>BookmarkToggle", mode = "n", desc = "添加删除bookmark" },
		{ "ma", "<Plug>BookmarkAnnotate", mode = "n", desc = "添加带描述的bookmark" },
		{ "mx", "<Plug>BookmarkClear", mode = "n", desc = "删除bookmark" },
		{ "ml", "<Plug>BookmarkShowAll", mode = "n", desc = "显示bookmark列表" },
		{ "m,", "<Plug>BookmarkPrev", mode = "n", desc = "上一个bookmark" },
		{ "m.", "<Plug>BookmarkNext", mode = "n", desc = "下一个bookmark" },
	},
	config = function()
		local g = vim.g
		-- WARN: 正常应该开启这个选项，但是开启之后，bookmarks会存储在打开项目的cwd根目录上
		-- 又不太好在项目的gitignore中增加这个的配置，所以先不开吧
		-- g.bookmark_save_per_working_dir = 1 -- 按项目保存 bookmarks
		g.bookmark_sign = "⚑" -- bookmark图标
		g.bookmark_annotation_sign = "☰" -- 带说明的bookmark图标
		g.bookmark_auto_save = 1 -- 自动保存bookmark
		g.bookmark_auto_close = 1 -- 跳转bookmarks的时候，自动关闭bookmark列表
		g.bookmark_highlight_lines = 1 -- 启用行高亮
		g.bookmark_no_default_key_mappings = 1 -- 禁用bookmark默认快捷键
		g.bookmark_display_annotation = 1 -- 在状态栏展示说明
		g.bookmark_location_list = 1 -- 使用loc list展示bookmark列表，而不是默认的quickfix
	end,
}
