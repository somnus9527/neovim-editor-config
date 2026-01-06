local M = {}
M.on_attach_pyright = function(client, _)
	client.server_capabilities.hoverProvider = true
end

M.on_attach_ruff = function(client, _)
	if client.name == "ruff" then
		-- disable hover in favor of pyright
		client.server_capabilities.hoverProvider = false
	end
end

return M
