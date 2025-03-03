return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    local fzf = require("fzf-lua")
    local config = fzf.config
    local actions = fzf.actions

    -- Quickfix
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
    config.defaults.keymap.fzf["alt-e"] = "abort"
    config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
    config.defaults.keymap.builtin["<alt-e>"] = "abort"

    -- Trouble
    if LazyVim.has("trouble.nvim") then
      config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
    end

    -- Toggle root dir / cwd
    config.defaults.actions.files["ctrl-r"] = function(_, ctx)
      local o = vim.deepcopy(ctx.__call_opts)
      o.root = o.root == false
      o.cwd = nil
      o.buf = ctx.__CTX.bufnr
      LazyVim.pick.open(ctx.__INFO.cmd, o)
    end
    config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
    config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

    local img_previewer ---@type string[]?
    for _, v in ipairs({
      { cmd = "ueberzug", args = {} },
      { cmd = "chafa", args = { "{file}", "--format=symbols" } },
      { cmd = "viu", args = { "-b" } },
    }) do
      if vim.fn.executable(v.cmd) == 1 then
        img_previewer = vim.list_extend({ v.cmd }, v.args)
        break
      end
    end

    return {
      "default-title",
      fzf_colors = true,
      fzf_opts = {
        ["--no-scrollbar"] = true,
      },
      defaults = {
        -- formatter = "path.filename_first",
        formatter = "path.dirname_first",
      },
      previewers = {
        builtin = {
          extensions = {
            ["png"] = img_previewer,
            ["jpg"] = img_previewer,
            ["jpeg"] = img_previewer,
            ["gif"] = img_previewer,
            ["webp"] = img_previewer,
          },
          ueberzug_scaler = "fit_contain",
        },
      },
      -- Custom LazyVim option to configure vim.ui.select
      ui_select = function(fzf_opts, items)
        return vim.tbl_deep_extend("force", fzf_opts, {
          prompt = " ",
          winopts = {
            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
            title_pos = "center",
          },
        }, fzf_opts.kind == "codeaction" and {
          winopts = {
            layout = "vertical",
            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
            width = 0.5,
            preview = not vim.tbl_isempty(LazyVim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
              layout = "vertical",
              vertical = "down:15,border-top",
              hidden = "hidden",
            } or {
              layout = "vertical",
              vertical = "down:15,border-top",
            },
          },
        } or {
          winopts = {
            width = 0.5,
            -- height is number of items, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
          },
        })
      end,
      winopts = {
        width = 0.8,
        height = 0.8,
        row = 0.5,
        col = 0.5,
        preview = {
          scrollchars = { "┃", "" },
        },
        on_create = function()
          LazyVim.safe_keymap_set("t", "<A-n>", "<Down>", { desc = "下移一个选项" })
          LazyVim.safe_keymap_set("t", "<A-m>", "<Up>", { desc = "上移一个选项" })
        end,
      },
      files = {
        cwd_prompt = false,
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["alt-h"] = { actions.toggle_hidden },
        },
      },
      grep = {
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["alt-h"] = { actions.toggle_hidden },
        },
      },
      lsp = {
        symbols = {
          symbol_hl = function(s)
            return "TroubleIcon" .. s
          end,
          symbol_fmt = function(s)
            return s:lower() .. "\t"
          end,
          child_prefix = false,
        },
        code_actions = {
          previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
        },
      },
    }
  end,
  keys = {
    { "<c-j>", false },
    { "<c-k>", false },
    { "<leader>,", false },
    { "<leader>/", false },
    { "<leader>sR", false },
    { "<leader>sw", false },
    { "<leader>sb", false },
    { "<leader>s", false },
    { "<leader>fr", false },
    { "<leader>ff", false },
    { "<leader>fF", false },
    { "<leader>uC", false },
    {
      "<leader>b",
      "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
      desc = "切换buffer",
    },
    { "<leader>.", LazyVim.pick("live_grep"), mode = "n", desc = "字符搜索(Root Dir)" },
    { "<leader>.", LazyVim.pick("grep_visual"), mode = "v", desc = "字符搜索 (Root Dir)" },
    { "<leader>,", "<cmd>FzfLua resume<cr>", desc = "重新打开" },
    { "<leader>/", '<cmd>lua require("fzf-lua").grep_curbuf()<CR>', desc = "字符搜索(当前Buffer)" },
    { "<leader>'", "<cmd>FzfLua registers<cr>", desc = "Registers" },
    { "<leader>o", "<cmd>FzfLua oldfiles<cr>", desc = "历史文件" },
    {
      "<leader>sr",
      "<cmd>lua require('fzf-lua').lsp_references({ ignore_current_line = true, includeDeclaration = false })<CR>",
      desc = "FZF搜索Reference",
    },
    { "<leader>si", "<cmd>lua require('fzf-lua').lsp_implementations()<CR>", desc = "FZF搜索implementations" },
    { "<leader>`", LazyVim.pick("colorschemes"), desc = "主题切换" },
  },
}
