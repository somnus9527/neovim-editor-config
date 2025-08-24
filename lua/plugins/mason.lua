return {
  {
    "mason-org/mason.nvim",
    version = "^1.0.0",
    config = true,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.0.0",
    opts = {
      ensure_installed = {
        "lua_ls",
        "vtsls",
        "cssls",
      },
      automatic_installation = true,
    },
    config = function(_,opts)
      require('mason-lspconfig').setup(opts)
    end
  }
}
