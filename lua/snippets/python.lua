local ok, ls = pcall(require, "luasnip")

if not ok then
	return {}
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local icon = "🚀"
local tag = "[Neovim AutoGR Log]"

return {

	------------------------------------------------------------------
	-- 基础：print
	------------------------------------------------------------------
	s("pr", {
		t('print(f"' .. icon .. tag .. " "),
		i(1),
		t('")'),
		i(0),
	}),
}
