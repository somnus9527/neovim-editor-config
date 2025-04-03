return {
  "akinsho/toggleterm.nvim",
  lazy = false,
  config = function()
    local toggleterm = require("toggleterm")
    toggleterm.setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      direction = "vertical",
      open_mapping = false,
      shade_terminals = true,
      start_in_insert = true,
      persist_size = false,
      winbar = {
        enabled = true,
      },
    })
    local Terminal = require("toggleterm.terminal").Terminal

    -- 创建垂直终端
    function _VTerm()
      Terminal:new():toggle(vim.o.columns * 0.4, "vertical")
    end

    -- 创建水平终端
    function _HTerm()
      Terminal:new():toggle(20, "horizontal")
    end

    -- Toggle所有终端
    function _ToggleTerm()
      vim.api.nvim_command("ToggleTermToggleAll")
    end

    -- 展示终端列表
    function _ListTerm()
      vim.api.nvim_command("TermSelect")
    end

    -- 绑定快捷键
    vim.keymap.set({ "n", "t" }, "<A-\\>", _VTerm, { silent = true, desc = "新开一个垂直终端" })
    vim.keymap.set({ "n", "t" }, "<A-/>", _HTerm, { silent = true, desc = "新开一个水平终端" })
    vim.keymap.set({ "n", "t" }, "<A-i>", _ToggleTerm, { silent = true, desc = "Toggle所以终端" })
    vim.keymap.set({ "n", "t" }, "<A-t>", _ListTerm, { silent = true, desc = "当前所有终端列表" })
  end,
}
