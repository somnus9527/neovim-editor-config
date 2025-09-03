return {
	"rest-nvim/rest.nvim",
	cmd = "Rest",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{
			"<leader>rr",
			"<CMD>Rest open<CR>",
			mode = "n",
			desc = "打开Rest",
		},
		{
			"<A-r>",
			"<CMD>Rest run<CR>",
			mode = "n",
			desc = "运行光标下的request",
		},
		{
			"<leader>rl",
			"<CMD>Rest logs<CR>",
			mode = "n",
			desc = "编辑日志",
		},
		{
			"<leader>rc",
			"<CMD>Rest cookies<CR>",
			mode = "n",
			desc = "编辑cookies",
		},
		{
			"<leader>ree",
			"<CMD>Rest env show<CR>",
			mode = "n",
			desc = "查看当前的环境变量",
		},
		{
			"<leader>res",
			"<CMD>Rest env select<CR>",
			mode = "n",
			desc = "选择环境变量",
		},
	},
	config = function()
		local rest = require("rest-nvim")
		local opts = {
			-- 自定义变量
			custom_dynamic_variables = {},
			request = {
				-- 跳过SSL鉴权,避免未知的令牌报错
				skip_ssl_verification = true,
				hooks = {
					---@type boolean 发起请求前Encode URL
					encode_url = true,
					---@type string 如果`User-Agent`为空，就设置
					user_agent = "rest.nvim v" .. require("rest-nvim.api").VERSION,
					---@type boolean 如果body不为空且`Content-Type`为空，就设置
					set_content_type = true,
				},
			},
			response = {
				hooks = {
					---@type boolean 对Request URL进行解码以提高可读性
					decode_url = true,
					---@type boolean 使用'gq'命令对相应进行格式化
					format = true,
				},
			},
			clients = {
				curl = {
					statistics = {
						{ id = "time_total", winbar = "take", title = "耗时" },
						{ id = "size_download", winbar = "size", title = "大小" },
					},
					opts = {
						---@type boolean 如果请求头包含`Accept-Encoding`，添加`--compressed`参数
						---`gzip`
						set_compressed = true,
						certificates = {},
					},
				},
			},
			cookies = {
				---@type boolean 是否支持cookie
				enable = false,
				---@type string cookie文件地址
				path = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "rest-nvim.cookies"),
			},
			-- 环境变量配置
			env = {
				---@type boolean
				enable = true,
				---@type string
				pattern = "^%.env$",
				---@type fun():string[]
				find = function()
					local config = require("rest-nvim.config")
					local path = vim.fs.find(function(name, _)
						return name:match(config.env.pattern)
					end, {
						path = vim.fn.getcwd(),
						type = "file",
						limit = math.huge,
					})
          print(path)
          return path
				end,
			},
			ui = {
				---@type boolean 是否在结果面板展示winbar
				winbar = true,
				---@class rest.Config.UI.Keybinds
				keybinds = {
					---@type string 跳转上一条结果面板
					prev = "<",
					---@type string 跳转吓一跳结果面板
					next = ">",
				},
			},
			---@class rest.Config.Highlight
			highlight = {
				---@type boolean 当前结果面板是否允许高亮
				enable = true,
				---@type number 高亮时间
				timeout = 750,
			},
			---@see vim.log.levels
			---@type integer log level
			_log_level = vim.log.levels.WARN,
		}
    rest.setup(opts)
	end,
}
