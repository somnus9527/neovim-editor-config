
-- 解析 .env 文件并加载环境变量
local function load_env_file(filepath)
	local env_file = io.open(filepath, "r")
	if not env_file then
		return
	end

	for line in env_file:lines() do
		for key, value in string.gmatch(line, "([%w_]+)=([%w_%.%-]+)") do
			vim.env[key] = value
		end
	end

	env_file:close()
end

-- 在这里指定 .env 文件的路径
local env_file_path = vim.fn.expand("~/.config/nvim/.env")

-- 加载 .env 文件
load_env_file(env_file_path)
