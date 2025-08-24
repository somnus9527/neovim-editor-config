return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_)
    local fzf = require("fzf-lua")
    local tools = require("tools.tools")
    local config = fzf.config
    local actions = fzf.actions

    -- Quickfix
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["alt-k"] = "half-page-up"
    config.defaults.keymap.fzf["alt-j"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
    config.defaults.keymap.fzf["alt-e"] = "abort"
    config.defaults.keymap.builtin["<a-j>"] = "preview-page-down"
    config.defaults.keymap.builtin["<a-k>"] = "preview-page-up"
    config.defaults.keymap.builtin["<alt-e>"] = "abort"

    -- Trouble
    -- if LazyVim.has("trouble.nvim") then
    --   config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
    -- end

    -- Toggle root dir / cwd
    -- config.defaults.actions.files["ctrl-r"] = function(_, ctx)
    --   local o = vim.deepcopy(ctx.__call_opts)
    --   o.root = o.root == false
    --   o.cwd = nil
    --   o.buf = ctx.__CTX.bufnr
    --   LazyVim.pick.open(ctx.__INFO.cmd, o)
    -- end
    -- config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
    -- config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

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
            width = 0.8,
            -- TODO: Lazyvim这个方法待实现
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
            width = 0.8,
            -- height is number of items, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
          },
        })
      end,
      winopts = {
        width = 0.9,
        height = 0.8,
        row = 0.8,
        col = 0.8,
        preview = {
          scrollchars = { "┃", "" },
        },
        on_create = function()
          local keymap = {
            { 't', '<A-n>', '<Down>', { desc = "下移一个选项" } },
            { 't', '<A-m>', '<Up>', { desc = "上移一个选项" } },
          }
          tools.set_buf_keymap(keymap)
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
  config = function(_, opts)
    if opts[1] == "default-title" then
      -- use the same prompt for all pickers for profile `default-title` and
      -- profiles that use `default-title` as base profile
      local function fix(t)
        t.prompt = t.prompt ~= nil and " " or nil
        for _, v in pairs(t) do
          if type(v) == "table" then
            fix(v)
          end
        end
        return t
      end
      opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
      opts[1] = nil
    end
    require("fzf-lua").setup(opts)
  end,
  init = function()
    local tools = require("tools.tools")
    tools.on_very_lazy(function()
      -- print('开始注册ui.select')
      local selecting = false
      vim.ui.select = function(...)
        if selecting then return end
        selecting = true
        require("lazy").load({ plugins = { "fzf-lua" } })
        require("fzf-lua").register_ui_select()
        selecting = false
        return vim.ui.select(...)
      end
    end)
  end,
  keys = {
    -- 放到win on_create回调中注册
    -- { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
    -- { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
    { "<leader><space>", "<cmd>lua require('fzf-lua').files()<cr>", mode = "n", desc = "文件搜索(CWD)" },
    { "<leader>.", "<cmd>lua require('fzf-lua').live_grep()<cr>", mode = "n", desc = "字符搜索(Root Dir)" },
    { "<leader>.", "<cmd>lua require('fzf-lua').grep_visual()<CR>", mode = "v", desc = "字符搜索 (Root Dir)" },
    { "<leader>,", "<cmd>lua require('fzf-lua').resume()<CR>", mode = "n", desc = "重打开" },
    { "<A-b>", "<cmd>lua require('fzf-lua').buffers()<CR>", mode = "n", desc = "打开Buffers" },
    -- 几乎不用
    -- { "<leader>l", "<cmd>lua require('fzf-lua').blines()<CR>", mode = "n", desc = "打开当前Buffer的行搜索" },
    { "<leader>/", "<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>", mode = "n", desc = "字符搜索(当前Buffer)" },
    { "<leader>w", "<cmd>lua require('fzf-lua').grep_cword()<CR>", mode = "n", desc = "WORD搜索(CWD)" },
    { "<leader>gc", "<cmd>lua require('fzf-lua').git_bcommits()<CR>", mode = "n", desc = "Git Buffer Commits" },
    { "<leader>gl", "<cmd>lua require('fzf-lua').git_commits()<CR>", mode = "n", desc = "Git Commits" },
    { "<leader>ca", "<cmd>lua require('fzf-lua').lsp_code_actions()<CR>", mode = "n", desc = "Lsp Code Actions" },
    { "<leader>lr", "<cmd>lua require('fzf-lua').lsp_references()<CR>", mode = "n", desc = "Lsp References" },
    { "<leader>ld", "<cmd>lua require('fzf-lua').lsp_definitions()<CR>", mode = "n", desc = "Lsp Definitions" },
    { "<leader>li", "<cmd>lua require('fzf-lua').lsp_implementations()<CR>", mode = "n", desc = "Lsp Implementations" },
    { "<leader>ls", "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>", mode = "n", desc = "Lsp Symbols" },
    { "<leader>lj", "<cmd>lua require('fzf-lua').lsp_incoming_calls()<CR>", mode = "n", desc = "Lsp Incoming Calls" },
    { "<leader>lk", "<cmd>lua require('fzf-lua').lsp_outgoing_calls()<CR>", mode = "n", desc = "Lsp Outgoing Calls" },
    { "<leader>`", "<cmd>lua require('fzf-lua').colorschemes()<CR>", mode = "n", desc = "Colorschemes" },
  },
}
