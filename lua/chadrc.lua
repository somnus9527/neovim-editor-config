-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.ui = {
  statusline = {
    theme = "minimal",
    separator_style = "arrow",
  },
  cmp = {
    lspkind_text = true,
    style = "atom",
  },
}

M.nvdash = {
  header = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "Somnus9527's Neovim Editor",
    "",
    "我从前单听他讲道理，也糊涂过去;",
    "现在晓得他讲道理的时候，",
    "不但唇边还抹着人油，",
    "而且心里满装着吃人的意思。",
    string.rep(" ", 18) .. "-- <<狂人日记>>",
    "",
    "",
  },
  buttons = {
    { txt = "  Find File", keys = "<Space><Space>", cmd = "FzfLua files" },
  },
  load_on_startup = true,
}

M.base46 = {
  theme = "tokyodark",

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.colorify = {
  enabled = true,
}

return M
