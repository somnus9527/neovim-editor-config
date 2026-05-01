local M = {}

-- 将 GitHub 仓库短路径转换为 vim.pack 可识别的插件来源。
local function gh(repo, spec)
	spec = spec or {}
	spec.src = "https://github.com/" .. repo
	return spec
end

--[[
将版本范围字符串转换为 vim.pack 使用的版本范围对象。
]]
local function range(version)
	return vim.version.range(version)
end

--[[
返回当前启用插件的 vim.pack 安装清单，已排除禁用插件。
]]
function M.all()
	return {
		gh("nvim-lua/plenary.nvim"),
		gh("nvim-tree/nvim-web-devicons"),
		gh("MunifTanjim/nui.nvim"),
		gh("nvim-mini/mini.nvim"),
		gh("rktjmp/lush.nvim"),
		gh("niuiic/omega.nvim"),
		gh("rcarriga/nvim-notify"),
		gh("b0o/schemastore.nvim"),
		gh("SmiteshP/nvim-navic"),
		gh("JoosepAlviste/nvim-ts-context-commentstring"),

		gh("ellisonleao/gruvbox.nvim", { name = "gruvbox" }),
		gh("folke/tokyonight.nvim"),
		gh("everviolet/nvim", { name = "evergarden" }),
		gh("rose-pine/neovim", { name = "rose-pine" }),
		gh("kuri-sun/yoda.nvim"),
		gh("zenbones-theme/zenbones.nvim"),
		gh("catppuccin/nvim", { name = "catppuccin" }),

		-- Mason 第一阶段固定在 v1，避免 vim.pack 的版本范围命中 v2 RC。
		gh("mason-org/mason.nvim", { version = "v1.11.0" }),
		gh("mason-org/mason-lspconfig.nvim", { version = "v1.32.0" }),
		gh("neovim/nvim-lspconfig"),
		gh("saghen/blink.cmp", { version = range("*") }),
		gh("bydlw98/blink-cmp-env"),
		gh("L3MON4D3/LuaSnip", { version = range("v2.*") }),
		gh("rafamadriz/friendly-snippets"),
		gh("saghen/blink.indent"),

		gh("nvim-treesitter/nvim-treesitter", { version = "main" }),
		gh("nvim-treesitter/nvim-treesitter-textobjects", { version = "main" }),
		gh("HiPhish/rainbow-delimiters.nvim"),
		gh("windwp/nvim-ts-autotag"),
		gh("mawkler/jsx-element.nvim"),

		gh("nvim-neo-tree/neo-tree.nvim"),
		gh("ibhagwan/fzf-lua"),
		gh("sindrets/diffview.nvim"),
		gh("folke/trouble.nvim"),
		gh("lewis6991/gitsigns.nvim"),
		gh("folke/flash.nvim"),
		gh("folke/noice.nvim"),
		gh("nvim-lualine/lualine.nvim"),
		gh("akinsho/bufferline.nvim"),
		gh("b0o/incline.nvim"),
		gh("utilyre/barbecue.nvim", { version = range("*"), name = "barbecue" }),
		gh("j-hui/fidget.nvim", { version = range("*") }),

		gh("MeanderingProgrammer/render-markdown.nvim"),
		gh("stevearc/conform.nvim"),
		gh("mfussenegger/nvim-lint"),
		gh("numToStr/Comment.nvim"),
		gh("kylechui/nvim-surround", { version = range("^3.0.0") }),
		gh("echasnovski/mini.pairs"),
		gh("echasnovski/mini.splitjoin"),
		gh("max397574/better-escape.nvim"),
		gh("itchyny/vim-cursorword"),
		gh("mg979/vim-visual-multi", { version = "master" }),
		gh("karb94/neoscroll.nvim"),
		gh("akinsho/toggleterm.nvim"),
		gh("nvim-pack/nvim-spectre"),
		gh("tomasky/bookmarks.nvim"),
		gh("cjodo/convert.nvim", { version = range("*") }),
		gh("Redoxahmii/json-to-types.nvim"),
		gh("zhisme/copy_with_context.nvim"),
		gh("danymat/neogen"),
		gh("nacro90/numb.nvim"),
		gh("nxhung2304/lastplace.nvim"),
		gh("folke/persistence.nvim"),
		gh("mcauley-penney/visual-whitespace.nvim"),
		gh("nvim-zh/colorful-winsep.nvim"),
		gh("petertriho/nvim-scrollbar"),
		gh("catgoose/nvim-colorizer.lua"),
		gh("mattn/emmet-vim"),
		gh("mistweaverco/kulala.nvim"),
		gh("mistricky/codesnap.nvim", { version = "v2.0.0-beta.17" }),
		gh("niuiic/git-log.nvim"),
		gh("Yu-Leo/blame-column.nvim"),
		gh("folke/todo-comments.nvim"),
		gh("olimorris/codecompanion.nvim", { version = "v18.7.0" }),
	}
end

return M
