return {
	{
		"mason-org/mason.nvim",
		version = "^1.0.0",
		config = true,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		version = "^1.0.0",
		opts = {
			ensure_installed = {
				"lua_ls",
				"vtsls",
				"cssls",
				"bashls",
				"css_variables",
				"cssmodules_ls",
				"html",
				"tailwindcss",
				"jsonls",
				-- 目前mason-lspconfig中还是叫volar,但是实际lspconfig已经改名vue_ls了，等这边同步再改，先自己安装
				-- "volar",
				"svelte",
				-- "emmet_ls",
				"yamlls",
			},
			automatic_installation = true,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},
}
