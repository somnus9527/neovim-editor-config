return {
  "karb94/neoscroll.nvim",
  event = { 'BufNewFile', 'BufReadPre' },
  config = function ()
    require('neoscroll').setup {}
    local t = {}
    -- Syntax: t[keys] = {function, {function arguments}}
    t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "250" } }
    t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "250" } }
    t["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } }
    -- t["<A-[>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } }
    -- t["<A-]>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } }
    t["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } }
    t["<C-y>"] = { "scroll", { "-0.10", "false", "100" } }
    t["<C-e>"] = { "scroll", { "0.10", "false", "100" } }
    t["zt"] = { "zt", { "250" } }
    t["zz"] = { "zz", { "250" } }
    t["zb"] = { "zb", { "250" } }
    t["<M-1>"] = { "scroll", { "0.50", "true", "100", [['circular']] } }
    t["<M-2>"] = { "scroll", { "-0.50", "true", "100", [['circular']] } }
    require('neoscroll.config').set_mappings(t)
  end
}
