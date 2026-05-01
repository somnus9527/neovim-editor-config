--[[
为 Neovim 0.12 兼容仍调用旧 API 的插件。
这些兼容代码只用于升级过渡，等相关插件全部适配后可以删除。
]]
if vim.text and vim.text.diff and not vim.diff then
	vim.diff = vim.text.diff
end

if vim.diagnostic then
	if not vim.diagnostic.disable then
		--[[
		兼容旧插件调用 vim.diagnostic.disable(bufnr, namespace) 的路径。
		Neovim 0.12 起应优先使用 vim.diagnostic.enable(false, opts)。

		入参 bufnr：需要关闭诊断的缓冲区编号，nil 表示沿用 Neovim 默认范围。
		入参 namespace：需要关闭的诊断命名空间，nil 表示不限定命名空间。
		返回值：本函数只产生诊断开关副作用，不返回业务数据。
		]]
		function vim.diagnostic.disable(bufnr, namespace)
			vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = namespace })
		end
	end

	if not vim.diagnostic.is_disabled then
		--[[
		兼容旧插件查询诊断禁用状态的路径。
		返回值保持旧 API 语义：true 表示诊断已禁用。

		入参 bufnr：需要查询诊断状态的缓冲区编号，nil 表示沿用 Neovim 默认范围。
		入参 namespace：需要查询的诊断命名空间，nil 表示不限定命名空间。
		返回值：当前范围内诊断是否处于禁用状态。
		]]
		function vim.diagnostic.is_disabled(bufnr, namespace)
			return not vim.diagnostic.is_enabled({ bufnr = bufnr, ns_id = namespace })
		end
	end
end
