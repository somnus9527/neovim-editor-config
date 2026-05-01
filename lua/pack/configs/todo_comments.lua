local M = {}

-- 构造 todo-comments 关键词配置，统一使用当前图标表里的 TODO 图标。
local function build_options()
	local icons = require("tools.icons")

	return {
		keywords = {
			FIX = {
				icon = icons.todo.Fix .. " ",
				color = "error",
				alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
			},
			TODO = { icon = icons.todo.Todo .. " ", color = "info", alt = { "TODO" } },
			HACK = { icon = icons.todo.Hack .. " ", color = "warning", alt = { "HACK" } },
			WARN = { icon = icons.todo.Warn .. " ", color = "warning", alt = { "WARNING", "XXX" } },
			PERF = { icon = icons.todo.Perf .. " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
			NOTE = { icon = icons.todo.Note .. " ", color = "hint", alt = { "INFO" } },
			TEST = { icon = icons.todo.Test .. " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
		},
	}
end

-- 注册 TODO 列表快捷键，默认走 FzfLua 展示所有 TODO 注释。
local function register_keys()
	vim.keymap.set("n", "<leader>tt", "<cmd>TodoFzfLua<CR>", {
		desc = "在FzfLua中展示所有TODO Comments",
		silent = true,
	})
end

-- 配置 todo-comments，并注册搜索入口快捷键。
function M.setup()
	require("todo-comments").setup(build_options())
	register_keys()
end

return M
