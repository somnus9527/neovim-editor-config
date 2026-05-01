local M = {}

-- 配置 nvim-web-devicons，并补充项目里常用文件的定制图标。
function M.setup()
	local devicons = require("nvim-web-devicons")

	devicons.setup({})
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
			icon = "⚡",
			color = "#646CFF",
			name = "ViteConfig",
		},
		["vite.config.js"] = {
			icon = "⚡",
			color = "#646CFF",
			name = "ViteConfig",
		},
	})
end

return M
