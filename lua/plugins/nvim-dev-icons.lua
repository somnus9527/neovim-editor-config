return {
	"nvim-tree/nvim-web-devicons",
	lazy = "VeryLazy",
	config = function(_, opts)
		local devicons = require("nvim-web-devicons")
		devicons.setup(opts)

		devicons.set_icon({
			css = {
				icon = "",
				color = "#563d7c",
				name = "Css",
			},
			["pnpm-workspace.yaml"] = {
				icon = "",
				color = "#f69220",
				name = "PnpmWorkspace",
			},
			["pnpm-lock.yaml"] = {
				icon = "",
				color = "#F69220",
				name = "PnpmLock",
			},
			["vite.config.ts"] = {
				icon = "⚡", -- Vite 可以用闪电
				color = "#646CFF", -- Vite 官方紫色
				name = "ViteConfig",
			},
			["vite.config.js"] = {
				icon = "⚡",
				color = "#646CFF",
				name = "ViteConfig",
			},
		})
	end,
}
