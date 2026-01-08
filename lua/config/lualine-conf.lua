local icons = require("tools.icons")
-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = '#202328',
  fg       = '#bbc2cf',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  darkblue = '#081633',
  green    = '#98be65',
  orange   = '#FF8800',
  violet   = '#a9a1e1',
  magenta  = '#c678dd',
  blue     = '#51afef',
  red      = '#ec5f67',
}

local conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
}
local function is_side_buffer()
	local ft = vim.bo.filetype
	local bt = vim.bo.buftype

	return ft == "neo-tree" or ft == "Neotree" or ft == "toggleterm" or bt == "terminal"
end

-- Config
local config = {
	options = {
		-- Disable sections and component separators
		component_separators = "",
		section_separators = "",
		theme = {
			-- We are going to use lualine_c an lualine_x as left and
			-- right section. Both are highlighted by c theme .  So we
			-- are just setting default looks o statusline
			normal = { c = { fg = colors.fg, bg = colors.bg } },
			inactive = { c = { fg = colors.fg, bg = colors.bg } },
		},
	},
	sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		-- These will be filled later
		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
	table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
	table.insert(config.sections.lualine_x, component)
end

ins_left({
	function()
		return "▊"
	end,
	color = { fg = colors.blue }, -- Sets highlighting of component
	padding = { left = 0, right = 1 }, -- We don't need space before this
})

ins_left({
	-- mode component
	function()
		return ""
	end,
	color = function()
		-- auto change color according to neovims mode
		local mode_color = {
			n = colors.red,
			i = colors.green,
			v = colors.blue,
			[""] = colors.blue,
			V = colors.blue,
			c = colors.magenta,
			no = colors.red,
			s = colors.orange,
			S = colors.orange,
			[""] = colors.orange,
			ic = colors.yellow,
			R = colors.violet,
			Rv = colors.violet,
			cv = colors.red,
			ce = colors.red,
			r = colors.cyan,
			rm = colors.cyan,
			["r?"] = colors.cyan,
			["!"] = colors.red,
			t = colors.red,
		}
		return { fg = mode_color[vim.fn.mode()] }
	end,
	padding = { right = 1 },
})

ins_left({
	"branch",
	icon = "",
	color = { fg = colors.violet, gui = "bold" },
})

ins_left({
	"filetype",
	icon_only = true,
	separator = "",
	padding = { left = 1, right = 0 },
	cond = function()
		return not is_side_buffer()
	end,
})

ins_left({
	"filename",
	cond = conditions.buffer_not_empty,
	color = { fg = colors.magenta, gui = "bold" },
	cond = function()
		return not is_side_buffer()
	end,
})

ins_left({
	"diagnostics",
	sources = { "nvim_diagnostic" },
	symbols = { error = icons.diagnostics.Error, warn = icons.diagnostics.Warn, info = icons.diagnostics.Info },
	diagnostics_color = {
		error = { fg = colors.red },
		warn = { fg = colors.yellow },
		info = { fg = colors.cyan },
	},
	cond = function()
		return not is_side_buffer()
	end,
})

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left({
	function()
		return "%="
	end,
	cond = function()
		return not is_side_buffer()
	end,
})

ins_left({
	-- Lsp server name .
	-- function()
	-- 	local msg = "No Active Lsp"
	-- 	local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
	-- 	local clients = vim.lsp.get_clients()
	-- 	if next(clients) == nil then
	-- 		return msg
	-- 	end
	-- 	for _, client in ipairs(clients) do
	-- 		local filetypes = client.config.filetypes
	-- 		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
	-- 			return client.name
	-- 		end
	-- 	end
	-- 	return msg
	-- end,
	-- icon = " LSP:",
	"datetime",
	style = "%Y-%m-%d %H:%M:%S",
	color = { fg = colors.red, gui = "bold" },
	cond = function()
		return not is_side_buffer()
	end,
})

ins_left({
	function()
		return "CTMD 爷真的累了"
	end,
	separator = "",
	padding = { left = 0, right = 0 },
	color = { fg = colors.red, gui = "bold" },
	-- cond = function() return not is_side_buffer() end,
})

ins_right({
	"location",
	padding = { left = 0, right = 1 },
	cond = function()
		return not is_side_buffer()
	end,
})

ins_right({
	"progress",
	padding = { left = 0, right = 1 },
	color = { fg = colors.fg, gui = "bold" },
	cond = function()
		return not is_side_buffer()
	end,
})

ins_right({
	-- filesize component
	"filesize",
	cond = function()
		return not is_side_buffer() and conditions.buffer_not_empty()
	end,
})

-- ins_right({
-- 	"lsp_status",
-- 	icon = "", -- f013
-- 	symbols = {
-- 		-- Standard unicode symbols to cycle through for LSP progress:
-- 		spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
-- 		-- Standard unicode symbol for when LSP is done:
-- 		done = "✓",
-- 		-- Delimiter inserted between LSP names:
-- 		separator = " ",
-- 	},
-- 	-- List of LSP names to ignore (e.g., `null-ls`):
-- 	ignore_lsp = {},
-- 	-- Display the LSP name
-- 	show_name = true,
--   cond = function() return not is_side_buffer() end,
-- })

-- Add components to right sections
ins_right({
	"o:encoding", -- option component same as &encoding in viml
	fmt = string.upper, -- I'm not sure why it's upper case either ;)
	color = { fg = colors.green, gui = "bold" },
	cond = function()
		return not is_side_buffer() and conditions.hide_in_width()
	end,
})

ins_right({
	"fileformat",
	-- symbols = {
	-- 	unix = "", -- e712
	-- 	dos = "", -- e70f
	-- 	mac = "", -- e711
	-- },
	fmt = string.upper,
	icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
	color = { fg = colors.green, gui = "bold" },
	cond = function()
		return not is_side_buffer()
	end,
})

ins_right({
	"diff",
	-- Is it me or the symbol for modified us really weird
	symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
	diff_color = {
		added = { fg = colors.green },
		modified = { fg = colors.orange },
		removed = { fg = colors.red },
	},
	cond = function()
		return not is_side_buffer() and conditions.hide_in_width()
	end,
})

ins_right({
	function()
		return "▊"
	end,
	color = { fg = colors.blue },
	padding = { left = 1 },
})

return config
