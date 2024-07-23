-- lazy.nvim
return {
	"chrisgrieser/nvim-tinygit",
	dependencies = {
		"stevearc/dressing.nvim",
		"rcarriga/nvim-notify", -- optional, but recommended
	},
	config = function ()
		local tinygit = require 'tinygit'
		local tools = require 'tools.tools'
		tinygit.setup()
		local keymaps = {
			{
				'n',
				'<leader>hl',
				function ()
					local tg = require 'tinygit'
					tg.lineHistory()
				end,
				{ desc = '搜索当前行的提交历史' }
			},
			{
				'n',
				'<leader>sa',
				function ()
					local tg = require 'tinygit'
					tg.stashPush()
				end,
				{
					desc = 'git statsh push'
				},
			},
			{
				'n',
				'<leader>sp',
				function ()
					local tg = require 'tinygit'
					tg.stashPop()
				end,
				{
					desc = 'git stash pop'
				}
			}
		}
		tools.set_keymap(keymaps)
	end
}
