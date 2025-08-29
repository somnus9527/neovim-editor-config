return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
	keys = {
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "切换Buffer固定" },
		{ "<leader>bx", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "删除所有未固定的Buffer" },
		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "删除右侧所有Buffer" },
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "删除左侧所有Buffer" },
		{ "<A-TAB>", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个Buffer" },
		{ "<TAB>", "<cmd>BufferLineCycleNext<cr>", desc = "下一个Buffer" },
		{ "<A-[>", "<cmd>BufferLineMovePrev<cr>", desc = "当前Buffer往前移" },
		{ "<A-]>", "<cmd>BufferLineMoveNext<cr>", desc = "当前Buffer往后移" },
		{ "-", "<cmd>bdelete<cr>", desc = "删除当前Buffer" },
	},
	opts = {
		options = {
			close_command = "bdelete! %d",
			right_mouse_command = "bdelete! %d",
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			diagnostics_indicator = function(_, _, diag)
				local icons = require("tools.icons")
				local diagnosticsIcons = icons.diagnostics
				local ret = (diag.error and diagnosticsIcons.Error .. diag.error .. " " or "")
					.. (diag.warning and diagnosticsIcons.Warn .. diag.warning or "")
				return vim.trim(ret)
			end,
			offsets = {
				{
					filetype = "neo-tree",
					text = "Neo-tree",
					highlight = "Directory",
					text_align = "left",
				},
				{
					filetype = "snacks_layout_box",
				},
			},
			get_element_icon = function(opts)
        local icon = require('nvim-web-devicons')
        return icon.get_icon_by_filetype(opts.filetype, { default = true })
			end,
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)
		-- Fix bufferline when restoring a session
		-- vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
		-- 	callback = function()
		-- 		vim.schedule(function()
		-- 			pcall(nvim_bufferline)
		-- 		end)
		-- 	end,
		-- })
	end,
}
