local tools = require("tools.tools")

local keymaps = {
  { "o", "(", "i(" },
  { "o", ")", "a(" },
  { "o", "[", "i[" },
  { "o", "]", "a[" },
  { "o", "<", "i<" },
  { "o", ">", "a<" },
  { "o", "{", "i{" },
  { "o", "}", "a}" },
  { "o", "'", "i'" },
  { "o", '"', 'i"' },
}

tools.set_keymap(keymaps)
