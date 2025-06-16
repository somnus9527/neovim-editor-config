return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      -- vim.list_extend(opts.ensure_installed, { "angular", "scss", "html", "css", "jsdoc" })
      vim.list_extend(opts.ensure_installed, { "scss", "html", "css", "jsdoc" })
    end
    if type(opts.ensure_installed) == "table" then
      opts.incremental_selection = vim.tbl_deep_extend("force", opts.incremental_selection or {}, {
        enable = true,
        keymaps = {
          init_selection = "<A-s>",
          node_incremental = "<A-s>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      })
    end
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      pattern = { "*.component.html", "*.container.html" },
      callback = function()
        vim.treesitter.start(nil, "angular")
      end,
    })
  end,
}
