return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    ensure_installed = {
      "c",
      "cpp",
      "dart",
      "dockerfile",
      "gitignore",
      "go",
      "graphql",
      "ini",
      "jsdoc",
      "python",
      "javascript",
      "typescript",
      "tsx",
      "html",
      "angular",
      "css",
      "scss",
      "svelte",
      "xml",
      "json5",
      "vue",
      "lua",
      "bash",
      "yaml",
      "markdown",
      "toml",
      "http",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
      disable = { "python" },
    },
    -- 最新版本已经移除，改到nvim-ts-context-commentstring中自动处理
    -- context_commentstring = { enable = true, enable_autocmd = false },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<A-w>",
        node_incremental = "<A-w>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
    textobjects = {
      select = {
        enable = false,
        -- lookahead = true,
        -- keymaps = {
        --   ["af"] = "@function.outer",
        --   ["if"] = "@function.inner",
        --   ["ac"] = "@class.outer",
        --   ["ic"] = "@class.inner",
        -- },
      },
      move = {
        enable = false,
        -- set_jumps = true,
        -- goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        -- goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
        -- goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        -- goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
      },
      swap = {
        enable = false,
        -- swap_next = { ["<leader>a"] = "@parameter.inner" },
        -- swap_previous = { ["<leader>A"] = "@parameter.inner" },
      },
    },
    matchup = { enable = true },
  },
  config = function(_, opts)
    local ts = require("nvim-treesitter.configs")

    -- 先注册 parser 配置
    ts.setup(opts)

    -- 安全 attach 检查函数
    local function should_skip(bufnr)
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      if not ok or not stats then return true end
      if stats.size > 500 * 1024 then return true end -- 大文件跳过

      local ft = vim.bo[bufnr].filetype
      local parser = require("nvim-treesitter.parsers").get_parser_configs()[ft]
      if not parser then return true end -- parser 不存在跳过

      return false
    end

    -- 自动控制 attach
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      callback = function(args)
        if should_skip(args.buf) then
          vim.treesitter.stop(args.buf)
        end
      end,
    })
  end,
}
