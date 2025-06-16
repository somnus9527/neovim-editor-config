return {
  "williamboman/mason.nvim",
  version = "2.*",
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, {
        "css-lsp",
        "css-variables-language-server",
        "cssmodules-language-server",
        "html-lsp",
        -- "angular-language-server",
      })
    end
  end,
}
