return {
  "williamboman/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "css-lsp")
    table.insert(opts.ensure_installed, "cssmodules-language-server")
  end,
}
