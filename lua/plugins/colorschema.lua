return {
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		name = "gruvbox",
    -- lazy = false,
    -- priority = 1000,
    -- config = function()
    --   vim.cmd.colorscheme("gruvbox")
    -- end
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		opts = { style = "moon" },
	},
	{
		"rose-pine/neovim",
		-- lazy = true,
		lazy = false,
		priority = 1000,
		name = "rose-pine",
		config = function()
			vim.cmd.colorscheme("rose-pine")
		end,
	},
	{
		"zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
    lazy = true,
		-- lazy = false,
		-- priority = 1000,
		-- config = function()
		-- 	vim.g.zenbones_darken_comments = 45
		-- 	vim.cmd.colorscheme("zenbones")
		-- end,
	},
	{
		"catppuccin/nvim",
		lazy = true,
		-- lazy = false,
		-- priority = 1000,
		name = "catppuccin",
		opts = {
			integrations = { blink_cmp = true },
		},
		-- config = function()
		-- 	vim.cmd.colorscheme("catppuccin")
		-- end,
	},
}
