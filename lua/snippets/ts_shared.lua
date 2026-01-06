local ok, ls = pcall(require, "luasnip")

if not ok then
	return {}
end

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
	------------------------------------------------------------------
	-- 泛型函数 + rep（高级但非常常用）
	------------------------------------------------------------------
	s(
		"gefn",
		fmt(
			[[
function {}<{}>({}): {} {{
  {}
}}
]],
			{
				i(1, "fn"),
				i(2, "T"),
				i(3),
				rep(2), -- 返回类型复用泛型 T
				i(0),
			}
		)
	),
}
