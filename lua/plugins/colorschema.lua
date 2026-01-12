return {
	{
		"ellisonleao/gruvbox.nvim",
		-- lazy = true,
		name = "gruvbox",
		lazy = false,
		priority = 1000,
		config = function()
		  vim.cmd.colorscheme("gruvbox")
		end
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		opts = { style = "moon" },
		-- lazy = false,
		-- config = function()
		-- 	vim.cmd.colorscheme("tokyonight")
		-- end,
	},
	{
		"everviolet/nvim",
		name = "evergarden",
		priority = 1000,
		lazy = true,
		-- opts = {
		-- 	theme = {
		-- 		variant = "fall",
		-- 		accent = "green",
		-- 	},
		-- 	editor = {
		-- 		transparent_background = false,
		-- 		sign = { color = "none" },
		-- 		float = {
		-- 			color = "mantle",
		-- 			solid_border = false,
		-- 		},
		-- 		completion = {
		-- 			color = "surface0",
		-- 		},
		-- 	},
		-- },
		-- lazy = false,
		-- config = function()
		-- 	vim.cmd.colorscheme("evergarden")
		-- end,
	},
	{
		"rose-pine/neovim",
		lazy = true,
		-- lazy = false,
		priority = 1000,
		name = "rose-pine",
		-- config = function()
		-- 	vim.cmd.colorscheme("rose-pine")
		-- end,
	},
	{
		"kuri-sun/yoda.nvim",
		lazy = true,
		-- lazy = false,
		-- config = function()
		-- 	vim.cmd.colorscheme("yoda")
		-- 	vim.cmd([[
  --       hi CursorLine guibg=#2b2b2b
  --     ]])
		-- end,
	},
	{
		"zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
		lazy = true,
		-- lazy = false,
		-- priority = 1000,
		-- config = function()
		-- 	vim.g.zenbones_darken_comments = 45
		-- 	vim.cmd.colorscheme("kanagawabones")
		-- end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		-- lazy = false,
		-- priority = 1000,
		-- opts = {
		-- 	integrations = { blink_cmp = true },
		-- },
		-- config = function()
		-- 	vim.cmd.colorscheme("catppuccin")
		-- end,
	},
}
